"""`OfferIn.content_hash()` mora biti stabilan IZMEDJU PROCESA, ne samo unutar jednog.

Zašto ovo mora biti provereno PRE nego što `OfferWriter` (ADR 0001 korak 4) počne da se
oslanja na `content_hash()` za detekciju "ponuda se nije promenila": svako pokretanje
`travelscrape run <izvor>` je NOV Python proces, i CPython po difoltu nasumično bira
`PYTHONHASHSEED` za svaki proces (osim ako je eksplicitno fiksiran). Ako bi poredak
ijednog polja u `OfferIn.content_hash()`-u zavisio od tog seed-a, ista ponuda bi
dobijala RAZLIČIT heš pri svakom skrepovanju — `OfferWriter` bi je tretirao kao
izmenjenu svaki put, i cela svrha content_hash-a (preskoči upis nepromenjene ponude)
bi tiho prestala da radi, bez ijednog pada testa u istom procesu.

`content_hash()` koristi `json.dumps(payload, sort_keys=True, ...)`, što sortira
ključeve REKURZIVNO na svakom nivou ugnježdenog dict-a — zato dict polja (npr.
`raw_attributes`) ne smeju biti osetljiva na poredak. Test to dokazuje eksperimentom
(dva zasebna procesa, dva različita hash seed-a), ne pretpostavkom o tome kako
`json.dumps` radi. `sort_keys` NE sortira sadržaj LISTI (`images`, `departures`, ...) —
te vrednosti u adapterima (soleazur/oktopod) dolaze iz dokument-reda, ne iz iteracije
seta, pa je test namerno fokusiran na dict polje gde je rizik stvaran.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

_SCRIPT = Path(__file__).parent / "_content_hash_case.py"


def _hash_with_seed(hash_seed: str) -> str:
    env = {**os.environ, "PYTHONHASHSEED": hash_seed}
    result = subprocess.run(
        [sys.executable, str(_SCRIPT)],
        capture_output=True,
        text=True,
        env=env,
        check=True,
    )
    return result.stdout.strip()


def test_content_hash_stable_across_processes() -> None:
    hash_seed_1 = _hash_with_seed("1")
    hash_seed_2 = _hash_with_seed("2")
    hash_seed_3 = _hash_with_seed("random")  # nasumičan seed, kao pravo pokretanje skrepera

    assert hash_seed_1 == hash_seed_2 == hash_seed_3
    assert len(hash_seed_1) == 64  # sha256 hex
