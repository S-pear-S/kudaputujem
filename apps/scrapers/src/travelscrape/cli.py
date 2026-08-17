"""CLI za travelscrape alat.

Komande:
    run       -- pokrenuti scraping za jedan izvor
    snapshot  -- preuzeti i ispisati jedan URL
    recon     -- profilisati sajt i zapisati docs/recon/<slug>.md
    replay    -- ponovo parsirati raw_document-e iz DB (nije implementirano)
    diff-raw  -- uporediti dve rune (nije implementirano)

Pokretanje:
    travelscrape run 1a-travel-letovanje
    travelscrape snapshot https://1atravel.rs/ponude/
    travelscrape recon 1a-travel https://1atravel.rs
"""

from __future__ import annotations

import asyncio
import logging
import re
import sys
from pathlib import Path

import httpx
import typer
from rich.console import Console
from rich.table import Table

# Uvoz adaptera okida @register dekoratore.
import travelscrape.adapters  # noqa: F401
from travelscrape.core import fetch as fetch_module
from travelscrape.core import registry
from travelscrape.core.fetch import (
    USER_AGENT,
    HttpFetcher,
    RobotsDisallowedError,
    SsrfError,
)
from travelscrape.core.pipeline import PipelineRunner
from travelscrape.core.settings import settings

console = Console()
app = typer.Typer(name="travelscrape", help="Kuda putujem scraper CLI")

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s %(name)s %(message)s",
)


# ---------------------------------------------------------------------------
# run
# ---------------------------------------------------------------------------


@app.command()
def run(
    source_slug: str = typer.Argument(..., help="Izvor koji treba skrepovati"),
    dry_run: bool = typer.Option(False, "--dry-run", help="Ne upisuje u bazu"),
    force: bool = typer.Option(
        False, "--force", help="Preskoči SUSPECT zaštitu (kraj sezone)"
    ),
    no_robots: bool = typer.Option(False, "--no-robots", help="Preskoči robots.txt proveru"),
    verbose: bool = typer.Option(False, "-v", "--verbose"),
) -> None:
    """Pokrenuti punu scraping runu za jedan izvor."""
    if verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    try:
        adapter = registry.get(source_slug)
    except KeyError as exc:
        console.print(f"[red]Greška:[/red] {exc}")
        raise typer.Exit(1) from exc

    if dry_run:
        console.print("[yellow]DRY RUN — podaci se neće upisati u bazu[/yellow]")

    console.print(f"Pokrećem [bold]{source_slug}[/bold]...")

    runner = PipelineRunner(settings)
    try:
        summary = runner.run(
            adapter,
            dry_run=dry_run,
            force=force,
            check_robots=not no_robots,
        )
    except Exception as exc:
        console.print(f"[red]Runa prekinuta: {exc}[/red]")
        raise typer.Exit(1) from exc

    _print_summary(summary)
    if summary.status != "OK":
        raise typer.Exit(1)


def _print_summary(summary: object) -> None:
    from travelcore.models import RunSummary

    assert isinstance(summary, RunSummary)
    color = "green" if summary.status == "OK" else "red"
    table = Table(title=f"Runa #{summary.run_id} — [{color}]{summary.status}[/{color}]")
    table.add_column("Metrika", style="bold")
    table.add_column("Vrednost")
    table.add_row("Izvor", summary.source_slug)
    table.add_row("Pronađeno", str(summary.items_found))
    table.add_row("Kreirano", str(summary.items_created))
    table.add_row("Ažurirano", str(summary.items_updated))
    table.add_row("Neizmenjeno", str(summary.items_updated))
    table.add_row("Neuspešno", str(summary.items_failed))
    table.add_row("Kompletnost (avg)", f"{summary.avg_completeness:.1%}")
    table.add_row("Trajanje", f"{summary.duration_seconds:.1f}s")
    if summary.error_message:
        table.add_row("Greška", summary.error_message)
    console.print(table)


# ---------------------------------------------------------------------------
# snapshot
# ---------------------------------------------------------------------------


@app.command()
def snapshot(
    url: str = typer.Argument(..., help="URL koji treba preuzeti"),
    output: Path | None = typer.Option(None, "-o", help="Sačuvati u fajl umesto stdout"),
    json_: bool = typer.Option(False, "--json", help="Prikaži zaglavlja kao JSON"),
) -> None:
    """Preuzeti jedan URL i ispisati HTML/JSON sadržaj."""

    async def _fetch() -> httpx.Response:
        # Za snapshot dozvoljeni su svi domeni (None = bez allowliste)
        async with HttpFetcher(allowed_domains=None) as fetcher:
            return await fetcher.get(url, check_robots=False)

    try:
        resp = asyncio.run(_fetch())
    except SsrfError as exc:
        console.print(f"[red]SSRF greška:[/red] {exc}")
        raise typer.Exit(1) from exc
    except Exception as exc:
        console.print(f"[red]Greška:[/red] {exc}")
        raise typer.Exit(1) from exc

    console.print(
        f"[dim]HTTP {resp.status_code} | "
        f"Content-Type: {resp.headers.get('content-type', '?')} | "
        f"{len(resp.content)} B[/dim]"
    )

    if output:
        output.write_bytes(resp.content)
        console.print(f"Sačuvano u [bold]{output}[/bold]")
    else:
        sys.stdout.write(resp.text)


# ---------------------------------------------------------------------------
# recon
# ---------------------------------------------------------------------------

_PLATFORMS = {
    "onesystem": ["onesystem-powered.png", "onesystem_wp_theme", "packagecountryid"],
    "b2cservice": ["SearchType", "search-router", "HpCode", "newcms.", "b2cservice."],
    "fibula": ["productType=2", "fibula"],
    "cloudhosting": ["cloudhosting.rs", "prevoz=autobus"],
    "wordpress": ["wp-content/", "wp-json/"],
}


@app.command()
def recon(
    slug: str = typer.Argument(..., help="Slug izvora (npr. 1a-travel)"),
    base_url: str = typer.Argument(..., help="Pocetni URL sajta"),
    output_dir: Path = typer.Option(
        Path("docs/recon"), "--output-dir", help="Folder za izlazni .md fajl"
    ),
) -> None:
    """Profilisati sajt i zapisati docs/recon/<slug>.md."""
    console.print(f"Recon za [bold]{slug}[/bold] ({base_url})...")

    async def _do_recon() -> dict:
        async with HttpFetcher(allowed_domains=None) as fetcher:
            return await _recon_site(fetcher, base_url)

    try:
        data = asyncio.run(_do_recon())
    except Exception as exc:
        console.print(f"[red]Greška:[/red] {exc}")
        raise typer.Exit(1) from exc

    md = _render_recon_md(slug, base_url, data)
    output_dir.mkdir(parents=True, exist_ok=True)
    out_path = output_dir / f"{slug}.md"
    out_path.write_text(md, encoding="utf-8")
    console.print(f"Zapisano: [bold]{out_path}[/bold]")


async def _recon_site(fetcher: HttpFetcher, base_url: str) -> dict:
    """Prikuplja info o sajtu: robots, sitemap, framework, API endpoints."""
    result: dict = {
        "base_url": base_url,
        "robots_txt": None,
        "sitemap_urls": [],
        "status_code": None,
        "content_type": None,
        "detected_platforms": [],
        "api_endpoints": [],
        "script_urls": [],
        "is_spa": False,
        "page_size_kb": None,
        "errors": [],
    }

    parsed = httpx.URL(base_url)
    scheme_host = f"{parsed.scheme}://{parsed.host}"

    # robots.txt
    try:
        robots_resp = await fetcher.get(f"{scheme_host}/robots.txt", check_robots=False)
        result["robots_txt"] = robots_resp.text[:2000]
        # Sitemap iz robots.txt
        for line in robots_resp.text.splitlines():
            if line.lower().startswith("sitemap:"):
                result["sitemap_urls"].append(line.split(":", 1)[1].strip())
    except Exception as exc:
        result["errors"].append(f"robots.txt: {exc}")

    # sitemap.xml ako nije u robots.txt
    if not result["sitemap_urls"]:
        try:
            sm = await fetcher.get(f"{scheme_host}/sitemap.xml", check_robots=False)
            if sm.is_success:
                result["sitemap_urls"].append(f"{scheme_host}/sitemap.xml")
        except Exception:
            pass

    # Glavna stranica
    try:
        main_resp = await fetcher.get(base_url, check_robots=False)
        result["status_code"] = main_resp.status_code
        result["content_type"] = main_resp.headers.get("content-type", "")
        result["page_size_kb"] = round(len(main_resp.content) / 1024, 1)
        html = main_resp.text

        # Detekcija platforme
        for platform, markers in _PLATFORMS.items():
            if any(m in html for m in markers):
                result["detected_platforms"].append(platform)

        # SPA detekcija: malo teksta u body, puno script tagova
        body_text = re.sub(r"<[^>]+>", "", html)
        result["is_spa"] = len(body_text.strip()) < 500 and "<script" in html

        # Script URL-ovi (potencijalni API endpointi u bundle-u)
        result["script_urls"] = re.findall(r'<script[^>]+src=["\']([^"\']+)["\']', html)[:10]

        # Trazimo JSON API pozive u HTML-u
        api_patterns = [
            r'(?:fetch|axios\.get|\.ajax)\(\s*["\']([^"\']+/api/[^"\']+)["\']',
            r'(?:fetch|axios\.get|\.ajax)\(\s*["\']([^"\']+\.json[^"\']*)["\']',
            r'url:\s*["\']([^"\']+/(?:search|offers|results)[^"\']*)["\']',
        ]
        endpoints: set[str] = set()
        for pattern in api_patterns:
            endpoints.update(re.findall(pattern, html))
        result["api_endpoints"] = sorted(endpoints)[:20]

    except Exception as exc:
        result["errors"].append(f"glavna stranica: {exc}")

    return result


def _render_recon_md(slug: str, base_url: str, data: dict) -> str:
    lines = [
        f"# Recon: {slug}",
        "",
        f"**URL:** {base_url}",
        f"**HTTP status:** {data.get('status_code', '?')}",
        f"**Content-Type:** {data.get('content_type', '?')}",
        f"**Veličina stranice:** {data.get('page_size_kb', '?')} KB",
        f"**SPA (JS-rendered):** {'da' if data.get('is_spa') else 'ne'}",
        "",
        "## Platforma",
        "",
    ]

    platforms = data.get("detected_platforms", [])
    if platforms:
        for p in platforms:
            lines.append(f"- **{p}** (detektovano)")
    else:
        lines.append("- Nije prepoznata automatski — pogledati HTML ručno")

    lines += [
        "",
        "## robots.txt",
        "",
        "```",
        (data.get("robots_txt") or "(nije dostupan)")[:1000],
        "```",
        "",
        "## Sitemap",
        "",
    ]

    sitemaps = data.get("sitemap_urls", [])
    if sitemaps:
        for s in sitemaps:
            lines.append(f"- {s}")
    else:
        lines.append("- Nije pronađen")

    api_eps = data.get("api_endpoints", [])
    if api_eps:
        lines += ["", "## Potencijalni API endpointi", ""]
        for ep in api_eps:
            lines.append(f"- `{ep}`")

    scripts = data.get("script_urls", [])
    if scripts:
        lines += ["", "## Script URL-ovi", ""]
        for s in scripts[:5]:
            lines.append(f"- `{s}`")

    errors = data.get("errors", [])
    if errors:
        lines += ["", "## Greške tokom recona", ""]
        for e in errors:
            lines.append(f"- {e}")

    lines += [
        "",
        "## Sledeći koraci",
        "",
        "- [ ] Identifikovati URL za listu svih ponuda",
        "- [ ] Utvrditi paginaciju (URL parametar, beskonačno skrolovanje, ...)",
        "- [ ] Proveriti da li su cene u HTML-u ili dolaze XHR-om",
        "- [ ] Proveriti `Disallow` u robots.txt pre pisanja adaptera",
        "",
        f"*Generisano sa `travelscrape recon {slug} {base_url}`*",
    ]
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# replay i diff-raw (stubs)
# ---------------------------------------------------------------------------


@app.command()
def replay(
    run_id: int = typer.Argument(..., help="ID rune čije dokumente ponovo parsirati"),
) -> None:
    """Ponovo parsirati raw_document-e iz baze za datu runu.

    Zahteva /internal/raw-documents endpoint koji još nije implementiran.
    """
    console.print("[yellow]replay nije još implementiran (čeka /internal/raw-documents endpoint)[/yellow]")
    raise typer.Exit(1)


@app.command(name="diff-raw")
def diff_raw(
    run_id1: int = typer.Argument(..., help="Prva runa"),
    run_id2: int = typer.Argument(..., help="Druga runa"),
) -> None:
    """Uporediti raw_document-e dve crawl rune.

    Zahteva /internal/raw-documents endpoint koji još nije implementiran.
    """
    console.print("[yellow]diff-raw nije još implementiran (čeka /internal/raw-documents endpoint)[/yellow]")
    raise typer.Exit(1)


# ---------------------------------------------------------------------------
# sources — bonus komanda za listu adaptera
# ---------------------------------------------------------------------------


@app.command()
def sources() -> None:
    """Ispisati listu svih registrovanih izvora."""
    slugs = registry.list_sources()
    if not slugs:
        console.print("[yellow]Nema registrovanih adaptera.[/yellow]")
        return
    table = Table(title="Registrovani izvori")
    table.add_column("source_slug", style="bold")
    for slug in slugs:
        table.add_row(slug)
    console.print(table)


if __name__ == "__main__":
    app()
