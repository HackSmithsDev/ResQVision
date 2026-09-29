"""Workspace category shells and base page lifecycle templates."""

from resq_command.pages.base import BaseCategoryShell, BasePage
from resq_command.pages.command.category_shell import CommandCategoryShell
from resq_command.pages.intel.category_shell import IntelCategoryShell
from resq_command.pages.logistics.category_shell import LogisticsCategoryShell
from resq_command.pages.tactical.category_shell import TacticalCategoryShell

__all__ = [
    "BasePage",
    "BaseCategoryShell",
    "TacticalCategoryShell",
    "IntelCategoryShell",
    "LogisticsCategoryShell",
    "CommandCategoryShell",
]