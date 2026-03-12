import subprocess
import json
import os
import time
from datetime import datetime
from typing import Optional

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "qwen3.5:9b"
OUTPUT_DIR = "assets/posts"
INDEX_FILE = "assets/posts.json"
BATCH_SIZE = 10  # Number of blog posts to generate in one run

# Diverse topic prompts — each post will have a unique angle
TOPICS = [
    "Flutter state management using Riverpod 2.x — advanced patterns, providers, and real-world architecture.",
    "Flutter animations deep dive: AnimationController, Tween, CurvedAnimation, and custom painters.",
    "Building offline-first Flutter apps with Isar database and sync strategies.",
    "Flutter performance profiling: identifying jank, reducing rebuilds, and using RepaintBoundary.",
    "Clean Architecture in Flutter: layered folder structure, separation of concerns, and dependency injection.",
    "Flutter navigation with GoRouter: nested routes, guards, deep linking, and query parameters.",
    "Building reusable Flutter design systems: themes, component libraries, and token-based styling.",
    "Flutter + Firebase: Firestore real-time listeners, security rules, and offline persistence.",
    "Flutter testing strategies: unit tests, widget tests, integration tests, and golden tests.",
    "Advanced Flutter widgets: CustomScrollView, Slivers, RenderObject custom layouts, and clipping.",
    "Dart 3 features every Flutter developer must know: records, patterns, sealed classes.",
    "Flutter background tasks: isolates, WorkManager, and platform channel communication.",
    "Building production-grade API clients in Flutter using Dio, interceptors, and retry logic.",
    "Flutter accessibility: semantics, screen reader support, contrast ratios, and inclusive design.",
    "Monetising Flutter apps: in-app purchases, subscriptions, and RevenueCat integration.",
]

# ─────────────────────────────────────────────────────────────────────────────
# Core functions
# ─────────────────────────────────────────────────────────────────────────────

def generate_single_post(topic: str, post_number: int, total: int) -> Optional[str]:
    """Generate a single blog post on `topic`. Returns the saved filepath or None."""

    prompt = f"""
    Write a high-quality, technical Flutter blog post in Markdown format.
    Topic: {topic}

    Structure:
    1. Title (H1) — make it specific and catchy
    2. Introduction — why this matters to Flutter developers
    3. Technical Deep Dive with real, working code snippets
    4. Best practices and pitfalls to avoid
    5. Conclusion with a clear takeaway

    Requirements:
    - Include at least 3 Dart/Flutter code blocks with explanations
    - Be opinionated and add your own expert insight
    - Aim for ~800-1200 words
    - Return ONLY the Markdown content. Do not include any preamble like "Here is your blog post".
    """

    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
    }

    print(f"\n[{post_number}/{total}] 🚀 Generating: {topic[:60]}...")

    try:
        result = subprocess.run(
            ['curl', '-s', '-X', 'POST', OLLAMA_URL, '-d', json.dumps(payload)],
            capture_output=True,
            text=True,
            timeout=600,
        )

        if result.returncode != 0:
            print(f"  ❌ curl failed: {result.stderr}")
            return None

        if not result.stdout.strip():
            print("  ❌ Empty response — is Ollama running?")
            return None

        try:
            data = json.loads(result.stdout)
        except json.JSONDecodeError:
            print(f"  ❌ JSON parse error: {result.stdout[:200]}")
            return None

        markdown_content = data.get("response", "")
        if not markdown_content:
            print(f"  ❌ No 'response' in payload: {data}")
            return None

        # Extract the H1 title
        title = f"Flutter: {topic[:50]}"
        for line in markdown_content.split('\n'):
            if line.startswith('# '):
                title = line.replace('# ', '').strip()
                break

        # Save to file — add a 1-second sleep so timestamps are always unique
        time.sleep(1)
        timestamp = datetime.now()
        id_str = timestamp.strftime("%Y%m%d%H%M%S")
        filename = f"blog_{id_str}.md"

        os.makedirs(OUTPUT_DIR, exist_ok=True)
        filepath = os.path.join(OUTPUT_DIR, filename)
        with open(filepath, "w") as f:
            f.write(markdown_content)

        print(f"  ✅ Saved: {filepath}")

        # Update the shared index
        excerpt = markdown_content[:150].replace('\n', ' ').strip() + "..."
        update_index(id_str, title, excerpt, filename)

        return filepath

    except subprocess.TimeoutExpired:
        print("  ⏱ Timed out waiting for Ollama (600 s).")
        return None
    except Exception as e:
        print(f"  ❌ Unexpected error: {e}")
        return None


def update_index(post_id: str, title: str, excerpt: str, filename: str) -> None:
    """Prepend a new post entry to posts.json."""
    posts = []
    if os.path.exists(INDEX_FILE):
        try:
            with open(INDEX_FILE, "r") as f:
                content = f.read().strip()
                if content:
                    posts = json.loads(content)
        except Exception as e:
            print(f"  ⚠️  Could not read index — starting fresh: {e}")
            posts = []

    posts.insert(0, {
        "id": post_id,
        "title": title,
        "excerpt": excerpt,
        "filename": filename,
        "date": datetime.now().isoformat(),
    })

    with open(INDEX_FILE, "w") as f:
        json.dump(posts, f, indent=2)

    print(f"  📄 Index updated ({len(posts)} posts total)")


def generate_batch(count: int = BATCH_SIZE) -> None:
    """Generate `count` blog posts sequentially."""

    # Pick diverse topics — cycle through the list if count > len(TOPICS)
    topics = [TOPICS[i % len(TOPICS)] for i in range(count)]

    print("=" * 65)
    print(f"  🏗  BATCH BLOG GENERATOR — {count} posts")
    print(f"  Model  : {MODEL}")
    print(f"  Output : {OUTPUT_DIR}/")
    print("=" * 65)

    start = time.time()
    successes = 0
    failures = 0

    for i, topic in enumerate(topics, start=1):
        filepath = generate_single_post(topic, i, count)
        if filepath:
            successes += 1
        else:
            failures += 1

    elapsed = time.time() - start
    mins, secs = divmod(int(elapsed), 60)

    print("\n" + "=" * 65)
    print(f"  ✅ Completed: {successes}/{count} posts generated")
    if failures:
        print(f"  ❌ Failed   : {failures}/{count} posts")
    print(f"  ⏱  Duration : {mins}m {secs}s")
    print("=" * 65)


# ─────────────────────────────────────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Batch Flutter blog generator powered by Ollama."
    )
    parser.add_argument(
        "--count",
        type=int,
        default=BATCH_SIZE,
        help=f"Number of posts to generate (default: {BATCH_SIZE})",
    )
    args = parser.parse_args()

    generate_batch(count=args.count)
