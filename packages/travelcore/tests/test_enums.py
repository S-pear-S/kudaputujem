"""Testovi za enume koji nose podatke (ADR 0001 korak 3, nalaz 2 iz poruke 9).

`PricingBasis.per_night`/`per_unit` su prepisani iz Kotlin
`enum class PricingBasis(val perNight: Boolean, val perUnit: Boolean)`.
Vrednosti su doslovno prepisane iz Kotlin definicije, ne ponovo izvedene.
"""

from __future__ import annotations

import pytest

from travelcore.enums import PricingBasis


@pytest.mark.parametrize(
    ("basis", "per_night", "per_unit"),
    [
        (PricingBasis.PER_PERSON_PER_STAY, False, False),
        (PricingBasis.PER_PERSON_PER_NIGHT, True, False),
        (PricingBasis.PER_UNIT_PER_STAY, False, True),
        (PricingBasis.PER_UNIT_PER_NIGHT, True, True),
    ],
)
def test_pricing_basis_per_night_per_unit(
    basis: PricingBasis, per_night: bool, per_unit: bool
) -> None:
    assert basis.per_night is per_night
    assert basis.per_unit is per_unit
