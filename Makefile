build_runner:
	dart run build_runner build
run-web:
	./flutterw run -d web-server --web-renderer html --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
