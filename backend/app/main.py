from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.config import settings
from .api.v1 import auth, destinations, hotels, transports, guides, bookings, payments, packages, admin, favorites, reviews, contact

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_PREFIX}/openapi.json"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(auth.router, prefix=settings.API_V1_PREFIX)
app.include_router(destinations.router, prefix=settings.API_V1_PREFIX)
app.include_router(hotels.router, prefix=settings.API_V1_PREFIX)
app.include_router(transports.router, prefix=settings.API_V1_PREFIX)
app.include_router(guides.router, prefix=settings.API_V1_PREFIX)
app.include_router(bookings.router, prefix=settings.API_V1_PREFIX)
app.include_router(payments.router, prefix=settings.API_V1_PREFIX)
app.include_router(packages.router, prefix=settings.API_V1_PREFIX)
app.include_router(packages.user_package_router, prefix=settings.API_V1_PREFIX)
app.include_router(admin.router, prefix=settings.API_V1_PREFIX)
app.include_router(favorites.router, prefix=settings.API_V1_PREFIX)
app.include_router(reviews.router, prefix=settings.API_V1_PREFIX)
app.include_router(contact.router, prefix=settings.API_V1_PREFIX)

@app.get("/")
def root():
    return {"message": "ComfyGo API is running"}

@app.get("/health")
def health():
    return {"status": "healthy"}
