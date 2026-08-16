"""Adapteri po platformi.

Svaki adapter se registruje dekoratorom @registry.register.
Ovde se importuju da bi se registracija pokrenula pri importu paketa.
"""

from . import soleazur as soleazur  # noqa: F401
