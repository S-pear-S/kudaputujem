"""Adapteri po platformi.

Svaki adapter se registruje dekoratorom @registry.register.
Ovde se importuju da bi se registracija pokrenula pri importu paketa.
"""

from . import oktopod as oktopod
from . import soleazur as soleazur
