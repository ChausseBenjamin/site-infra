#!/bin/bash

# Hugo Cache Optimization Script
# This script optimizes your Hugo site for better caching
# Works alongside tools/progressivify.sh

echo "🚀 Starting Hugo cache optimization..."

# Build the site with cache optimization
echo "📦 Building Hugo site with optimizations..."
cd data && hugo --gc --minify --environment production

# Go back to root directory
cd ..

# Run progressivify script on portfolio images
echo "🖼️ Running progressivify on portfolio images..."
PROGRESSIVE_SCRIPT=tools/progressivify.sh
PORTFOLIO_DIR=data/public/portfolio

if [ -f "$PROGRESSIVE_SCRIPT" ] && [ -d "$PORTFOLIO_DIR" ]; then
    $PROGRESSIVE_SCRIPT $PORTFOLIO_DIR
    echo "✅ Portfolio images optimized"
else
    echo "⚠️ Progressivify script or portfolio directory not found, skipping..."
fi

# Compress other images further (optional - requires imagemin)
if command -v imagemin &> /dev/null; then
    echo "🖼️ Optimizing other images..."
    find data/public -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | grep -v "portfolio" | xargs imagemin --replace
fi

# Generate cache manifest in project root for deployment tools
echo "📄 Generating cache manifest..."
find data/public -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.svg" -o -name "*.pdf" \) | sed 's|data/public||' > cache-manifest.txt

# Create resource hints file for documentation
echo "⚡ Creating resource hints..."
cat > resource-hints.txt << 'EOF'
# Resource hints for better performance
# Add these to your HTML head for critical pages:

<!-- DNS prefetch for external resources -->
<link rel="dns-prefetch" href="//fonts.googleapis.com">
<link rel="dns-prefetch" href="//cdnjs.cloudflare.com">

<!-- Preload critical resources -->
<link rel="preload" href="/style.css" as="style">
<link rel="preload" href="/vendor/fontawesome/css/all.min.css" as="style">

<!-- Prefetch next likely pages -->
<link rel="prefetch" href="/photography">
<link rel="prefetch" href="/misc/chaussebenjamin-fr.pdf">
<link rel="prefetch" href="/misc/chaussebenjamin-en.pdf">

# Usage in nginx.conf:
# add_header Link "</style.css>; rel=preload; as=style";
# add_header Link "</vendor/fontawesome/css/all.min.css>; rel=preload; as=style";
EOF

# Set optimal file permissions
echo "🔒 Setting file permissions..."
find data/public -type f -exec chmod 644 {} \;
find data/public -type d -exec chmod 755 {} \;

echo "✅ Cache optimization complete!"
echo "📊 Site statistics:"
echo "   Total files: $(find data/public -type f | wc -l)"
echo "   Total size: $(du -sh data/public | cut -f1)"
echo "   HTML files: $(find data/public -name "*.html" | wc -l)"
echo "   CSS files: $(find data/public -name "*.css" | wc -l)"
echo "   JS files: $(find data/public -name "*.js" | wc -l)"
echo "   Images: $(find data/public \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.svg" \) | wc -l)"
echo "   Portfolio images: $(find data/public/portfolio -name "lr-*.jpg" 2>/dev/null | wc -l)"
