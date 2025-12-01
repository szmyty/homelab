#!/usr/bin/env python3
"""
Generate Runtipi manifests from service metadata.yml files.

This script reads metadata.yml files from services/ directories
and generates Runtipi-compatible JSON manifest files.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    print("Error: PyYAML not installed. Install with: pip install pyyaml")
    sys.exit(1)


def load_metadata(service_path: Path) -> dict[str, Any] | None:
    """Load metadata.yml from a service directory."""
    metadata_file = service_path / "metadata.yml"

    if not metadata_file.exists():
        return None

    with open(metadata_file, "r") as f:
        return yaml.safe_load(f)


def generate_runtipi_manifest(metadata: dict[str, Any]) -> dict[str, Any]:
    """Generate Runtipi manifest from service metadata."""
    manifest = {
        "$schema": "https://raw.githubusercontent.com/runtipi/runtipi/main/packages/worker/assets/config.schema.json",
        "name": metadata.get("name", ""),
        "id": metadata.get("id", metadata.get("name", "").lower().replace(" ", "-")),
        "description": metadata.get("description", ""),
        "short_desc": metadata.get("short_description", metadata.get("description", "")[:100]),
        "author": metadata.get("author", ""),
        "source": metadata.get("source", ""),
        "available": metadata.get("available", True),
        "version": metadata.get("version", "1.0.0"),
        "tipiVersion": 1,
        "port": metadata.get("port", 80),
        "categories": metadata.get("categories", []),
        "form_fields": [],
    }

    # Add form fields if defined
    if "environment" in metadata:
        for env_var in metadata["environment"]:
            field = {
                "type": env_var.get("type", "text"),
                "label": env_var.get("label", env_var.get("name", "")),
                "env_variable": env_var.get("name", ""),
                "required": env_var.get("required", False),
            }
            if "default" in env_var:
                field["default"] = env_var["default"]
            manifest["form_fields"].append(field)

    return manifest


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Generate Runtipi manifests from service metadata"
    )
    parser.add_argument(
        "--services-dir",
        type=Path,
        default=Path("services"),
        help="Path to services directory (default: services)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("manifests/runtipi"),
        help="Output directory for manifests (default: manifests/runtipi)",
    )
    parser.add_argument(
        "--service",
        type=str,
        help="Generate manifest for specific service only",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print manifests without writing files",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Verbose output",
    )

    args = parser.parse_args()

    # Resolve paths relative to script location
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent

    services_dir = repo_root / args.services_dir
    output_dir = repo_root / args.output_dir

    if not services_dir.exists():
        print(f"Error: Services directory not found: {services_dir}")
        return 1

    # Create output directory
    if not args.dry_run:
        output_dir.mkdir(parents=True, exist_ok=True)

    # Process services
    service_dirs = [services_dir / args.service] if args.service else sorted(services_dir.iterdir())

    generated_count = 0

    for service_path in service_dirs:
        if not service_path.is_dir():
            continue

        service_name = service_path.name

        if args.verbose:
            print(f"Processing: {service_name}")

        metadata = load_metadata(service_path)

        if metadata is None:
            if args.verbose:
                print(f"  Skipping: No metadata.yml found")
            continue

        manifest = generate_runtipi_manifest(metadata)

        if args.dry_run:
            print(f"\n=== {service_name} ===")
            print(json.dumps(manifest, indent=2))
        else:
            output_file = output_dir / f"{manifest['id']}.json"
            with open(output_file, "w") as f:
                json.dump(manifest, f, indent=2)
            print(f"Generated: {output_file}")

        generated_count += 1

    print(f"\nGenerated {generated_count} manifest(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
