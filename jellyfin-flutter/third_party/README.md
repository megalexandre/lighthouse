# Third-party code

## media_kit_video 2.0.1 (patched)

[media_kit_video](https://github.com/media-kit/media-kit) 2.0.1 from pub.dev
(MIT, see `media_kit_video/LICENSE`), without its `example/`, with one patch:
`media_kit_video-wayland-egl.patch` (`linux/video_output.cc`).
`pubspec.yaml` points at this copy through `dependency_overrides`.

**Why.** On Linux, media_kit draws video on the GPU by sharing the EGL
display that is *current* when the player is created
(`eglGetCurrentDisplay`). GTK only keeps its EGL context current while it
draws a frame, so there often is none at that moment: media_kit printed
`VideoOutput: EGL display or context is invalid`, fell back to software
rendering (`S/W rendering`), and every frame went through the CPU. 1080p
was visibly choppy (Ubuntu 24.04, GNOME on Wayland, Intel + NVIDIA).

**What the patch does.** When no EGL context is current and GDK is on
Wayland, it takes the EGLDisplay of GDK's Wayland connection, the way GTK
gets it (`eglGetPlatformDisplayEXT(EGL_PLATFORM_WAYLAND_EXT, wl_display)`,
else `eglGetDisplay(wl_display)`; EGL returns the same display for the
same native display), and chooses an RGBA8 GLES 2 config itself. Not
`eglGetPlatformDisplay`: it is EGL 1.5, and with no display in use yet
libepoxy cannot tell it exists and aborts the app ("No provider of
eglGetPlatformDisplay found"). Frames reach Flutter as EGLImages, which only need that
shared display, not Flutter's context. It prints
`VideoOutput: Using the Wayland EGL display (no current context).` X11 and
the case where a context is current are unchanged.

**Updating media_kit_video.** Copy the new version here (no `example/`),
reapply the patch (`patch -p1 -d media_kit_video < media_kit_video-wayland-egl.patch`),
and check video is hardware rendered on Wayland (the line above, no
`S/W rendering`). Drop the copy once upstream handles it.
