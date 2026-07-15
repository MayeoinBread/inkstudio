# InkStudio

InkStudio is a cross-platform Flutter application for creating, managing and synchronising content for compatible 4-colour e-paper display devices.

It provides an offline-first workflow for building image libraries, generating notes and QR codes, previewing processed output, and synchronising content over Bluetooth Low Energy (BLE).

InkStudio is fully usable without a connected device. A device connection is only required when transferring content.

InkStudio currently supports the PicPak panel only.

---

# Latest Release

v0.2.0 introduces support for Albums (see below).

If upgrading the app, ensure on first run to connect to the panel and press the "Sync" button so the App knows what images are currently on the panel.

---

# Features

## Cross-platform

InkStudio runs from a single Flutter codebase on:

- Windows
- Android

The interface adapts automatically between desktop and mobile layouts.

As the app is built using Flutter, the code may already work on iOS devices. I do not own/use Apple devices and will not be directly building support for them.

## Offline-first Library

All content is stored locally on the device. The device/app acts as the source of truth. Features include:

- Organise images into albums
- Browse and edit existing content
- Delete and clean up unused images
- Prepare updates without a device connection
- Import an image per device slot
- Multi-image import (fills next empty slot)

No cloud services or internet connection required.

## Albums

Albums allow users to organise and manage multiple collections of images for their panel.

Each album represents a complete panel layout, containing all available slots. Users can create, rename, delete, and switch between albums from the library. Switching albums changes the active image collection shown in the library without affecting the images stored in other albums.

The app tracks the relationship between albums and connected devices, allowing each panel to maintain its own deployed state. When an album is selected, the app compares the album contents against the last known state of the connected device and identifies which slots require updating.

This allows users to maintain multiple panel layouts and switch between different image collections while only transferring the required changes during synchronisation.

## Content Creation

InkStudio supports multiple content sources:

- Imported images
- Text notes
- QR codes
- Procedural test images

All content is processed through a unified pipeline for consistent device output.

## Image Processing

Built-in tools include:

- Image cropping and rotation
- Brightness adjustment
- Contrast adjustment
- Extensible filter system

## Dithering

Supported dithering algorithms include:

- None
- Floyd–Steinberg
- Atkinson
- Ordered
- Sierra
- Stucki
- Burkes
- JJN

## Filters

Multiple filters are available to change the style of the image including:

- Grayscale
- Posterise
- Comic
- Halftone
- Pencil Sketch
- Inverted
- Sepia
- Adaptive B&W Threshold

Images are converted into the device’s fixed four-colour palette:

- Black
- White
- Yellow
- Red

## Preview

Real-time preview is generated directly from the framebuffer used for transmission, ensuring accurate representation of final device output.

## Device Synchronisation

When connected to a compatible device, InkStudio can:

- Push pending updates
- Synchronise album contents (show what is out of sync on the device)
- Transfer packed framebuffers over BLE
- Validate transfers using MD5 hashes
- Download images from the device (processed only)

InkStudio remains fully functional offline.

---

# Design Principles

- Offline-first by default
- Cross-platform from a single codebase
- Unified processing pipeline for all content types
- Clear separation of UI, processing and transport layers
- Predictable output for constrained colour displays

---

# Current Limitations

- BLE synchronisation requires compatible hardware
- Image processing is CPU-intensive on low-end devices
- No cloud synchronisation
- No user accounts
- No GPU acceleration

---

# Roadmap

Planned improvements:

- Enhanced note editing tools
- Expanded QR generation options
- Improved editing UX on mobile
- Performance optimisations

---

# AI Assistance Disclosure

Portions of this project were developed with the assistance of AI tooling for architecture planning, documentation, boilerplate generation, refactoring assistance and code review.

All generated code is reviewed, tested and maintained by human contributors. Final design and implementation decisions remain the responsibility of the project maintainers.
