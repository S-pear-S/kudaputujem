package rs.kudaputujem.api.common

import java.text.Normalizer

/**
 * Normalizacija teksta. MORA da daje isti rezultat kao SQL `norm_text()` i kao
 * Python `travelscrape.normalize.text.normalize()`.
 *
 * Ako se ova tri razidju, alias tabele prestanu da pogadjaju i sistem tiho pravi duplikate.
 */
object Text {

    private val LATIN = mapOf(
        'č' to "c", 'ć' to "c", 'ž' to "z", 'š' to "s", 'đ' to "dj",
        'Č' to "C", 'Ć' to "C", 'Ž' to "Z", 'Š' to "S", 'Đ' to "Dj",
    )

    private val CYRILLIC = mapOf(
        'а' to "a", 'б' to "b", 'в' to "v", 'г' to "g", 'д' to "d", 'ђ' to "dj",
        'е' to "e", 'ж' to "z", 'з' to "z", 'и' to "i", 'ј' to "j", 'к' to "k",
        'л' to "l", 'љ' to "lj", 'м' to "m", 'н' to "n", 'њ' to "nj", 'о' to "o",
        'п' to "p", 'р' to "r", 'с' to "s", 'т' to "t", 'ћ' to "c", 'у' to "u",
        'ф' to "f", 'х' to "h", 'ц' to "c", 'ч' to "c", 'џ' to "dz", 'ш' to "s",
    )

    private val NON_ALNUM = Regex("[^a-z0-9]+")
    private val SLUG_TRIM = Regex("^-+|-+$")

    fun deaccent(input: String): String {
        val builder = StringBuilder(input.length)
        for (ch in input) {
            val lower = ch.lowercaseChar()
            when {
                CYRILLIC.containsKey(lower) -> {
                    val mapped = CYRILLIC.getValue(lower)
                    builder.append(if (ch.isUpperCase()) mapped.replaceFirstChar { it.uppercase() } else mapped)
                }
                LATIN.containsKey(ch) -> builder.append(LATIN.getValue(ch))
                else -> builder.append(ch)
            }
        }
        return Normalizer.normalize(builder, Normalizer.Form.NFKD)
            .filter { Character.getType(it) != Character.NON_SPACING_MARK.toInt() }
    }

    fun normalize(input: String): String =
        NON_ALNUM.replace(deaccent(input).lowercase(), " ").trim()

    fun slugify(input: String, maxLength: Int = 80): String {
        val slug = NON_ALNUM.replace(deaccent(input).lowercase(), "-")
        return SLUG_TRIM.replace(slug, "").take(maxLength).let { SLUG_TRIM.replace(it, "") }
    }
}
