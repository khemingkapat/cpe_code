"""
Utility functions for the text_analytics project.
Shared across subdirectories (e.g., regex, text_vis, etc.).
"""

from pathlib import Path

# Paths
PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = PROJECT_ROOT / "data"

def get_data_path(filename: str) -> Path:
    """
    Get absolute path to a file inside the central 'data/' directory.

    Example usage:
        books_path = get_data_path("books.txt")
    """
    return DATA_DIR / filename


def extract_books(file_path: str | Path | None = None, raw_text: str | None = None) -> dict[str, dict]:
    """
    Extract Harry Potter books from text content into a dictionary structure.
    Logic matched from regex/Lab1_regex.ipynb (Section 4).

    Parameters:
        file_path: Path to the text file. Defaults to data/books.txt if not provided.
        raw_text: Optional raw text string. If provided, overrides file_path.

    Returns:
        dict: A dictionary where keys are book titles and values are dicts with keys:
              - 'content': list of line strings
              - 'start': start index in filtered lines
              - 'end': end index in filtered lines
    """
    if raw_text is None:
        if file_path is None:
            file_path = get_data_path("books.txt")
        with open(file_path, encoding="utf-8") as f:
            raw_text = f.read()

    raw_lines = raw_text.split("\n")
    lines = [item for item in raw_lines if item]

    books = {}
    current_book = ""

    for idx, line in enumerate(lines):
        if line == "Harry Potter":
            current_book = line + " " + lines[idx + 1]
            books[current_book] = {
                "content": [line],
                "start": idx,
                "end": idx + 1,
            }
        else:
            if current_book in books:
                books[current_book]["content"].append(line)
                books[current_book]["end"] += 1

    return books


