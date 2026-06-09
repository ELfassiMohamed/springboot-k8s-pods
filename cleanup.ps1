# Clean up temporary files
Remove-Item -Path graphify_ast_script.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_detect_test.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_extract_test.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_detect_test2.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_full_extract.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_build_test.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_generate.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_export.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_generate_fixed.py -Force -ErrorAction SilentlyContinue
Remove-Item -Path finalize.ps1 -Force -ErrorAction SilentlyContinue
Remove-Item -Path check_files.ps1 -Force -ErrorAction SilentlyContinue
Remove-Item -Path check_final.ps1 -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_result.json -Force -ErrorAction SilentlyContinue
Remove-Item -Path graphify_full_result.json -Force -ErrorAction SilentlyContinue
