{{flutter_js}}
{{flutter_build_config}}

// Disable Flutter's service worker — it often breaks Safari / GitHub Pages
// by serving stale shells and hanging registration in WebKit.
_flutter.loader.load({
  config: {
    canvasKitVariant: 'full',
  },
});
