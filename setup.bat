pyinstaller ^
    --name="carp" ^
    --console ^
    --onefile ^
    --noconfirm ^
    --clean ^
    --hidden-import="CarpParser" ^
    CarpTranspiler.py