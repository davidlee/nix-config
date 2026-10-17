"""Exit non-zero, naming them, unless every LiteLLM model id in argv is in
the packaged price map (proxy.nix's configDir build). Finds the map without
importing litellm, whose import needs network settings a build lacks."""

import json
import sys
from importlib.util import find_spec
from pathlib import Path

package = Path(find_spec("litellm").submodule_search_locations[0])
prices = json.loads(
    (package / "model_prices_and_context_window_backup.json").read_text()
)
missing = [model for model in sys.argv[1:] if model not in prices]
if missing:
    sys.exit(f"llm-gateway: not in the packaged price map: {', '.join(missing)}")
