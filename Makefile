.PHONY: setup help

help:
	@echo "Available commands:"
	@echo "  make setup - Run the interactive setup script"

setup:
	@bash setup.sh
