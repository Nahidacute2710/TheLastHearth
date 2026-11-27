extends Node
## Global signal hub. Declares signals only: no state, no logic.

## An Interactable started or stopped detecting the player body.
signal interactable_available(interactable: Interactable)
signal interactable_unavailable(interactable: Interactable)
## The interactable the player would use when pressing interact (null when none).
signal interaction_focus_changed(interactable: Interactable)
