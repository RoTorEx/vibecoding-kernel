.PHONY: vibe-propose

vibe-propose:
	@test -f .vibe/KERNEL_SOURCE || { echo "Missing .vibe/KERNEL_SOURCE. Run: make vibe-kernel-set" >&2; exit 1; }
	@kernel_root="$$(sed -n '1p' .vibe/KERNEL_SOURCE)"; \
	test -f "$$kernel_root/tools/vibe-propose" || { echo "Missing $$kernel_root/tools/vibe-propose. Update the kernel source first." >&2; exit 1; }; \
	python3 "$$kernel_root/tools/vibe-propose" .
