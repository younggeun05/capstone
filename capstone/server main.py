from fastapi import FastAPI, UploadFile, File, Form, Depends
from fastapi.responses import JSONResponse, FileResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import shutil
import uuid
import os

app = FastAPI()

# 웹 연결을 위한 CORS 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # 필요한 주소만 허용
    allow_methods=["*"],
    allow_headers=["*"],
)

# 파일 저장 폴더 생성
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# SQLAlchemy 설정
DATABASE_URL = "sqlite:///./products.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Product 모델 정의
class Product(Base):
    __tablename__ = "products"
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    price = Column(Integer, nullable=False)
    model_url = Column(String, nullable=False)
    thumbnail_url = Column(String, nullable=False)

Base.metadata.create_all(bind=engine)

# DB 세션 의존성
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/upload")
async def upload_product(
    name: str = Form(...),
    price: int = Form(...),
    model: UploadFile = File(...),
    thumbnail: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    # 유효성 검사
    if not name or name.strip() == "":
        return JSONResponse(content={"error": "상품명을 입력하세요."}, status_code=400)
    if price < 0:
        return JSONResponse(content={"error": "가격은 0 이상이어야 합니다."}, status_code=400)
    if model.filename == "" or thumbnail.filename == "":
        return JSONResponse(content={"error": "파일을 선택하세요."}, status_code=400)

    try:
        product_id = str(uuid.uuid4())
        model_path = os.path.join(UPLOAD_DIR, f"{product_id}_{model.filename}")
        thumb_path = os.path.join(UPLOAD_DIR, f"{product_id}_{thumbnail.filename}")

        with open(model_path, "wb") as f:
            shutil.copyfileobj(model.file, f)
        with open(thumb_path, "wb") as f:
            shutil.copyfileobj(thumbnail.file, f)

        product = Product(
            id=product_id,
            name=name,
            price=price,
            model_url=model_path,
            thumbnail_url=thumb_path
        )
        db.add(product)
        db.commit()
        db.refresh(product)
        return JSONResponse(content={
            "message": "상품 업로드 성공",
            "product": {
                "id": product.id,
                "name": product.name,
                "price": product.price,
                "model_url": product.model_url,
                "thumbnail_url": product.thumbnail_url
            }
        })
    except Exception as e:
        return JSONResponse(content={"error": f"서버 에러: {str(e)}"}, status_code=500)

@app.get("/products")
async def get_products(db: Session = Depends(get_db)):
    products = db.query(Product).all()
    return [
        {
            "id": p.id,
            "name": p.name,
            "price": p.price,
            "model_url": p.model_url,
            "thumbnail_url": p.thumbnail_url
        }
        for p in products
    ]

# 파일 업로드 시 확장자 및 크기 제한 예시
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

@app.post("/upload-swift")
async def upload_swift(file: UploadFile = File(...)):
    # 유효성 검사
    if not file.filename.endswith(".swift"):
        return JSONResponse(content={"error": "Swift 파일만 업로드 가능합니다."}, status_code=400)
    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
        return JSONResponse(content={"error": "파일 크기가 너무 큽니다."}, status_code=400)
    if file.filename == "":
        return JSONResponse(content={"error": "파일명을 입력하세요."}, status_code=400)
    try:
        save_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(save_path, "wb") as f:
            f.write(contents)
        return {"filename": file.filename}
    except Exception as e:
        return JSONResponse(content={"error": f"서버 에러: {str(e)}"}, status_code=500)

@app.get("/swift-files")
async def list_swift_files():
    files = [f for f in os.listdir(UPLOAD_DIR) if f.endswith(".swift")]
    return files

@app.get("/swift-files/{filename}")
async def download_swift_file(filename: str):
    file_path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        return JSONResponse(content={"error": "파일이 존재하지 않습니다."}, status_code=404)
    return FileResponse(file_path, media_type="text/plain", filename=filename)

@app.get("/swift-files/{filename}/view")
async def view_swift_file(filename: str):
    file_path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        return HTMLResponse(content="<h1>파일이 존재하지 않습니다.</h1>", status_code=404)
    with open(file_path, "r", encoding="utf-8") as f:
        code = f.read()
    html = f"<h2>{filename}</h2><pre style='background:#222;color:#eee;padding:1em;'>{code}</pre>"
    return HTMLResponse(content=html)