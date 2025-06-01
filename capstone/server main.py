# main.py
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse, FileResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
import shutil
import uuid
import os

app = FastAPI()

# 웹 연결을 위한 CORS 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프론트 개발 중이므로 전체 허용
    allow_methods=["*"],
    allow_headers=["*"],
)

# 메모리에 저장될 상품 목록
products = []

# 파일 저장 폴더 생성
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/upload")
async def upload_product(
    name: str = Form(...),
    price: int = Form(...),
    model: UploadFile = File(...),
    thumbnail: UploadFile = File(...)
):
    product_id = str(uuid.uuid4())

    model_path = os.path.join(UPLOAD_DIR, f"{product_id}_{model.filename}")
    thumb_path = os.path.join(UPLOAD_DIR, f"{product_id}_{thumbnail.filename}")

    with open(model_path, "wb") as f:
        shutil.copyfileobj(model.file, f)
    with open(thumb_path, "wb") as f:
        shutil.copyfileobj(thumbnail.file, f)

    product = {
        "id": product_id,
        "name": name,
        "price": price,
        "model_url": model_path,
        "thumbnail_url": thumb_path
    }
    products.append(product)
    return JSONResponse(content={"message": "상품 업로드 성공", "product": product})

@app.get("/products")
async def get_products():
    return products

# Swift 파일 업로드 엔드포인트 (기존 /upload 재사용 가능)
@app.post("/upload-swift")
async def upload_swift(file: UploadFile = File(...)):
    if not file.filename.endswith(".swift"):
        return JSONResponse(content={"error": "Swift 파일만 업로드 가능합니다."}, status_code=400)
    save_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(save_path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    return {"filename": file.filename}

# 업로드된 Swift 파일 목록
@app.get("/swift-files")
async def list_swift_files():
    files = [f for f in os.listdir(UPLOAD_DIR) if f.endswith(".swift")]
    return files

# Swift 파일 다운로드
@app.get("/swift-files/{filename}")
async def download_swift_file(filename: str):
    file_path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        return JSONResponse(content={"error": "파일이 존재하지 않습니다."}, status_code=404)
    return FileResponse(file_path, media_type="text/plain", filename=filename)

# Swift 파일 내용 보기 (브라우저에서)
@app.get("/swift-files/{filename}/view")
async def view_swift_file(filename: str):
    file_path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        return HTMLResponse(content="<h1>파일이 존재하지 않습니다.</h1>", status_code=404)
    with open(file_path, "r", encoding="utf-8") as f:
        code = f.read()
    html = f"<h2>{filename}</h2><pre style='background:#222;color:#eee;padding:1em;'>{code}</pre>"
    return HTMLResponse(content=html)
