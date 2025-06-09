from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from fastapi import Request
from fastapi.middleware.cors import CORSMiddleware
import pyodbc
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Templates
templates = Jinja2Templates(directory="templates")

# Database connection settings
server = 'DANIYAL\\SQLEXPRESS'
database = 'METAMOOD'
conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'

def get_connection():
    return pyodbc.connect(conn_str)

# Pydantic models

# Define Bid model first
class Bid(BaseModel):
    BidID: int
    NFTID: int
    BidderID: int
    Amount: float
    BidTime: datetime

# Then define models that use Bid
class NFT(BaseModel):
    Title: str
    Description: str
    CollectionID: Optional[int] = None
    OwnerID: int

class UserDetail(BaseModel):
    UserID: int
    Username: str

class CollectionDetail(BaseModel):
    CollectionID: int
    CollectionName: str

class NFTDetail(BaseModel):
    NFTID: int
    Title: str
    Description: str
    OwnerID: int
    CollectionID: Optional[int] = None
    MintedAt: datetime
    ListingPrice: Optional[float] = None
    ViewCount: int = 0
    Tags: List[str] = []
    Owner: UserDetail
    Collection: Optional[CollectionDetail] = None
    Bids: List[Bid] = []

class Collection(BaseModel):
    CollectionID: int
    CollectionName: str
    CreatorID: int
    CategoryID: Optional[int] = None

class UserCreate(BaseModel):
    Username: str
    Email: str
    PublicKey: str

class Wallet(BaseModel):
    WalletID: int
    UserID: int
    PublicKey: str
    Balance: float # Use float or Decimal based on your needs and pyodbc conversion

class UserLogin(BaseModel):
    Username: str
    Email: str

class Report(BaseModel):
    ReportID: int
    ReporterID: int
    NFTID: int
    Reason: Optional[str] = None
    ReportedAt: str # Adjust type if needed

class ReportWithDetails(BaseModel):
    ReportID: int
    ReporterUsername: str
    NFTTitle: str
    Reason: Optional[str] = None
    ReportedAt: str

class ReportCreate(BaseModel):
    ReporterUsername: str
    NFTID: int
    Reason: Optional[str] = None

class Category(BaseModel):
    CategoryID: int
    CategoryName: str

# New Pydantic model for creating a bid
class BidCreate(BaseModel):
    NFTID: int
    BidderUsername: str
    BidAmount: float

class CollectionCreate(BaseModel):
    CollectionName: str
    CreatorID: int
    CategoryID: Optional[int] = None

class CategoryCreate(BaseModel):
    CategoryName: str

# Routes
@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/nfts")
async def get_nfts_page(request: Request):
    # Get user_id from session or query parameter
    user_id = request.query_params.get("user_id")
    return templates.TemplateResponse("index.html", {"request": request, "user_id": user_id})

# Add a new API endpoint to get all NFTs as JSON
@app.get("/api/nfts")
def get_all_nfts_api():
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM NFTs")
        columns = [column[0] for column in cursor.description]
        nfts = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return nfts
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@app.post("/nfts")
def create_nft(nft: NFT):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO NFTs (Title, Description, CollectionID, OwnerID)
            VALUES (?, ?, ?, ?)
        """, (nft.Title, nft.Description, nft.CollectionID, nft.OwnerID))
        conn.commit()
        return {"message": "NFT created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/users")
def get_users():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Users")
        columns = [column[0] for column in cursor.description]
        users = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return users
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/create-nft", response_class=HTMLResponse)
async def create_nft_form(request: Request):
    return templates.TemplateResponse("nft_form.html", {"request": request})

@app.get("/nfts/{nft_id}", response_class=HTMLResponse)
async def get_nft_page(request: Request, nft_id: int):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Query 1: Get basic NFT details, Listing Price
        cursor.execute("""
            SELECT
                N.NFTID, N.Title, N.Description, N.MintedAt, N.OwnerID, N.CollectionID,
                L.Price
            FROM NFTs N
            LEFT JOIN Listings L ON N.NFTID = L.NFTID
            WHERE N.NFTID = ?
        """, (nft_id,))
        nft_row = cursor.fetchone()

        if nft_row is None:
            raise HTTPException(status_code=404, detail="NFT not found")

        # Extract data from the single joined row
        nft_data = {
            "NFTID": nft_row[0],
            "Title": nft_row[1],
            "Description": nft_row[2],
            "MintedAt": nft_row[3],
            "OwnerID": nft_row[4],
            "CollectionID": nft_row[5],
            "ListingPrice": nft_row[6]
        }

        # Query 2: Get Owner details
        cursor.execute("SELECT UserID, Username FROM Users WHERE UserID = ?", (nft_data["OwnerID"],))
        owner_row = cursor.fetchone()
        owner = UserDetail(UserID=owner_row[0], Username=owner_row[1]) if owner_row else None

        # Query 3: Get Collection details (if CollectionID exists)
        collection = None
        if nft_data["CollectionID"] is not None:
            cursor.execute("SELECT CollectionID, CollectionName FROM Collections WHERE CollectionID = ?", (nft_data["CollectionID"],))
            collection_row = cursor.fetchone()
            collection = CollectionDetail(CollectionID=collection_row[0], CollectionName=collection_row[1]) if collection_row else None

        # Query 4: Get View Count
        cursor.execute("SELECT COUNT(*) FROM NFT_Views WHERE NFTID = ?", (nft_id,))
        view_count = cursor.fetchone()[0]

        # Increment view count by adding a new view record
        try:
            cursor.execute("""
                INSERT INTO NFT_Views (NFTID, ViewerID, ViewedAt)
                VALUES (?, ?, GETDATE())
            """, (nft_id, 1))
            conn.commit()
        except Exception as view_error:
            print(f"Error inserting new view for NFT {nft_id}: {view_error}")
            # Don't raise an error, just log it and continue

        # Query 5: Get Tags
        cursor.execute("""
            SELECT t.TagName
            FROM Tags t
            INNER JOIN NFT_Tags nt ON t.TagID = nt.TagID
            WHERE nt.NFTID = ?
        """, (nft_id,))
        tag_rows = cursor.fetchall()
        tags = [row[0] for row in tag_rows]

        # Query 6: Get Bids for the NFT's active listing
        bids = []
        # First, find the active ListingID for this NFT
        cursor.execute("SELECT ListingID FROM Listings WHERE NFTID = ? AND IsActive = 1", (nft_id,))
        listing_row = cursor.fetchone()
        listing_id = listing_row[0] if listing_row else None

        if listing_id:
            cursor.execute("""
                SELECT b.BidID, b.BidAmount, b.BidAt, b.BidderID, u.Username AS BidderUsername
                FROM Bids b
                INNER JOIN Users u ON b.BidderID = u.UserID
                WHERE b.ListingID = ?
                ORDER BY b.BidAmount DESC
            """, (listing_id,))
            bid_rows = cursor.fetchall()
            bids = [{
                "BidID": row[0],
                "BidAmount": float(row[1]),
                "BidAt": str(row[2]),
                "BidderID": row[3],
                "BidderUsername": row[4]
            } for row in bid_rows]

        # Combine data for the template
        template_data = {
            "NFTID": nft_data["NFTID"],
            "Title": nft_data["Title"],
            "Description": nft_data["Description"],
            "MintedAt": str(nft_data["MintedAt"]),
            "Owner": {"UserID": nft_data["OwnerID"], "Username": owner.Username if owner else "Unknown"},
            "Collection": {"CollectionID": nft_data["CollectionID"], "CollectionName": collection.CollectionName if collection else "N/A"} if collection else None,
            "ListingPrice": nft_data["ListingPrice"],
            "ViewCount": view_count + 1,
            "Tags": tags,
            "Bids": bids, # Include fetched bids
        }

        # Pass the fetched data to the template, including user_id
        user_id = request.query_params.get("user_id") # Get user_id from query parameter
        return templates.TemplateResponse("nft_detail.html", {"request": request, "nft": template_data, "user_id": user_id})

    except Exception as e:
        print(f"Error fetching NFT {nft_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@app.get("/collections", response_class=HTMLResponse)
async def get_collections_page(request: Request):
    user_id = request.query_params.get("user_id")
    return templates.TemplateResponse("collections.html", {"request": request, "user_id": user_id})

@app.get("/login", response_class=HTMLResponse)
async def get_login_page(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/register", response_class=HTMLResponse)
async def get_register_page(request: Request):
    return templates.TemplateResponse("register.html", {"request": request})

@app.get("/api/collections", response_model=List[Collection])
def get_all_collections():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT CollectionID, CollectionName, CreatorID, CategoryID FROM Collections")
        columns = [column[0] for column in cursor.description]
        collections = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return collections
    except Exception as e:
        print(f"Error fetching collections: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/login")
def login_user(user: UserLogin):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Check if user exists
        cursor.execute("""
            SELECT UserID FROM Users 
            WHERE Username = ? AND Email = ?
        """, (user.Username, user.Email))
        
        result = cursor.fetchone()
        if result:
            user_id = result[0]
            return {"message": "Login successful", "user_id": user_id}
        else:
            raise HTTPException(status_code=401, detail="Invalid credentials")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@app.post("/api/register")
def register_user(user: UserCreate):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Check if username or email already exists
        cursor.execute("""
            SELECT UserID FROM Users 
            WHERE Username = ? OR Email = ?
        """, (user.Username, user.Email))
        
        if cursor.fetchone():
            raise HTTPException(status_code=400, detail="Username or email already exists")
        
        # Insert new user
        cursor.execute("""
            INSERT INTO Users (Username, Email, PublicKey)
            VALUES (?, ?, ?)
        """, (user.Username, user.Email, user.PublicKey))
        
        # Get the new user's ID
        cursor.execute("SELECT SCOPE_IDENTITY()") # Get the last inserted ID
        user_id = cursor.fetchone()[0]
        
        # Create wallet for the new user
        cursor.execute("""
            INSERT INTO Wallets (UserID, PublicKey, Balance)
            VALUES (?, ?, 0.0)
        """, (user_id, user.PublicKey))
        conn.commit()
        
        return {"user_id": user_id, "message": "User registered successfully"}
        
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Add endpoint to get a user's wallet details
@app.get("/api/users/{user_id}/wallet", response_model=Wallet)
def get_user_wallet(user_id: int):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Check if the user exists first (optional but good practice)
        cursor.execute("SELECT UserID FROM Users WHERE UserID = ?", (user_id,))
        user_exists = cursor.fetchone()
        if not user_exists:
            raise HTTPException(status_code=404, detail="User not found")

        # Fetch wallet details for the user
        cursor.execute("SELECT WalletID, UserID, PublicKey, Balance FROM Wallets WHERE UserID = ?", (user_id,))
        wallet_row = cursor.fetchone()

        if wallet_row is None:
            raise HTTPException(status_code=404, detail="Wallet not found for this user")
            
        wallet_data = dict(zip([column[0] for column in cursor.description], wallet_row))
        
        return Wallet(**wallet_data)

    except Exception as e:
        print(f"Error fetching wallet for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Add a route to serve the user's wallet page
@app.get("/users/{user_id}/wallet", response_class=HTMLResponse)
async def get_wallet_page(request: Request, user_id: int):
    # We don't fetch data here, the frontend JS will do that via the API endpoint
    return templates.TemplateResponse("wallet.html", {"request": request, "user_id": user_id})

@app.get("/reports", response_class=HTMLResponse)
async def get_reports_page(request: Request):
    user_id = request.query_params.get("user_id")
    return templates.TemplateResponse("reports.html", {"request": request, "user_id": user_id})

# Add endpoint to get all reports with details
@app.get("/api/reports", response_model=List[ReportWithDetails])
def get_all_reports():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Fetch reports with reporter username and NFT title
        cursor.execute("""
            SELECT 
                r.ReportID, r.Reason, r.ReportedAt,
                u.Username AS ReporterUsername,
                n.Title AS NFTTitle
            FROM Reports r
            INNER JOIN Users u ON r.ReporterID = u.UserID
            INNER JOIN NFTs n ON r.NFTID = n.NFTID
            ORDER BY r.ReportedAt DESC
        """
        )
        
        columns = [column[0] for column in cursor.description]
        reports = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        # Format ReportedAt as string
        for report in reports:
            report["ReportedAt"] = str(report["ReportedAt"])

        return reports

    except Exception as e:
        print(f"Error fetching reports: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Add endpoint to submit a new report
@app.post("/api/reports")
def create_report(report: ReportCreate):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Find the UserID based on the provided ReporterUsername
        cursor.execute("SELECT UserID FROM Users WHERE Username = ?", (report.ReporterUsername,))
        user_row = cursor.fetchone()

        if user_row is None:
            raise HTTPException(status_code=400, detail="Invalid Reporter Username")
            
        reporter_id = user_row[0]

        # Optional: Validate NFTID exists (already have this check)
        cursor.execute("SELECT NFTID FROM NFTs WHERE NFTID = ?", (report.NFTID,))
        if cursor.fetchone() is None:
            raise HTTPException(status_code=400, detail="Invalid NFT ID")

        # Insert new report into Reports table using the found ReporterID
        # ReportedAt will default to GETDATE()
        cursor.execute("INSERT INTO Reports (ReporterID, NFTID, Reason) VALUES (?, ?, ?)", 
                       (reporter_id, report.NFTID, report.Reason))
        conn.commit()
        
        return {"message": "Report submitted successfully"}

    except Exception as e:
        conn.rollback() # Rollback changes if anything fails
        print(f"Error submitting report: {e}")
        
        # Check for specific validation errors from our manual checks
        if "Invalid Reporter Username" in str(e) or "Invalid NFT ID" in str(e):
             raise HTTPException(status_code=400, detail=str(e))

        raise HTTPException(status_code=500, detail="An error occurred while submitting the report.")

# Route to serve the categories page
@app.get("/categories", response_class=HTMLResponse)
async def read_categories(request: Request):
    user_id = request.query_params.get("user_id")
    return templates.TemplateResponse("categories.html", {"request": request, "user_id": user_id})

# API endpoint to get all categories
@app.get("/api/categories", response_model=list[Category])
async def get_categories():
    conn = None
    cursor = None
    categories = []
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute("SELECT CategoryID, CategoryName FROM Categories")
        rows = cursor.fetchall()
        for row in rows:
            categories.append(Category(CategoryID=row[0], CategoryName=row[1]))
    except Exception as e:
        print(f"Error fetching categories: {e}")
        raise HTTPException(status_code=500, detail="Error fetching categories")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
    return categories

@app.post("/api/bids")
async def create_bid(bid: BidCreate):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # 1. Verify NFT exists and has an active listing
        cursor.execute("SELECT ListingID FROM Listings WHERE NFTID = ? AND IsActive = 1", (bid.NFTID,))
        listing_row = cursor.fetchone()
        if not listing_row:
            raise HTTPException(status_code=400, detail=f"NFT with ID {bid.NFTID} is not currently listed for sale.")

        listing_id = listing_row[0]

        # 2. Find the UserID based on the provided Username
        cursor.execute("SELECT UserID FROM Users WHERE Username = ?", (bid.BidderUsername,))
        user_row = cursor.fetchone()
        if not user_row:
             # Using 400 for bad request due to invalid Username
            raise HTTPException(status_code=400, detail=f"User with username '{bid.BidderUsername}' does not exist.")

        bidder_id = user_row[0]

        # 3. Insert the new bid using the found BidderID
        cursor.execute("""
            INSERT INTO Bids (ListingID, BidderID, BidAmount, BidAt)
            VALUES (?, ?, ?, GETDATE())
        """, (listing_id, bidder_id, bid.BidAmount))

        conn.commit()

        return {"message": "Bid placed successfully!"}

    except HTTPException as http_exc:
        # Re-raise HTTPException to be handled by FastAPI
        raise http_exc
    except Exception as e:
        # Log the full error for debugging
        print(f"Error creating bid: {e}")
        # Return a 500 Internal Server Error for other exceptions
        raise HTTPException(status_code=500, detail=f"Failed to place bid: {e}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# New endpoint to get bids for a specific NFT
@app.get("/api/nfts/{nft_id}/bids")
async def get_bids_for_nft(nft_id: int):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Find the active listing ID for the NFT
        cursor.execute("SELECT ListingID FROM Listings WHERE NFTID = ? AND IsActive = 1", (nft_id,))
        listing_row = cursor.fetchone()
        listing_id = listing_row[0] if listing_row else None

        if not listing_id:
            # If no active listing, return an empty list of bids
            return []

        # Get bids for the active listing, including bidder username
        cursor.execute("""
            SELECT b.BidID, b.BidAmount, b.BidAt, b.BidderID, u.Username AS BidderUsername
            FROM Bids b
            INNER JOIN Users u ON b.BidderID = u.UserID
            WHERE b.ListingID = ?
            ORDER BY b.BidAmount DESC -- Show highest bid first
        """, (listing_id,))
        bid_rows = cursor.fetchall()

        # Convert bid rows to a list of dictionaries
        bids = [{
            "BidID": row[0],
            "BidAmount": float(row[1]),
            "BidAt": str(row[2]),
            "BidderID": row[3],
            "BidderUsername": row[4]
        } for row in bid_rows]

        return bids

    except Exception as e:
        print(f"Error fetching bids for NFT {nft_id}: {e}")
        # Return an empty list and a 500 error for other exceptions
        raise HTTPException(status_code=500, detail=f"Failed to fetch bids: {e}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@app.post("/api/collections")
def create_collection(collection: CollectionCreate):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Insert new collection and get the new ID
        cursor.execute("""
            INSERT INTO Collections (CollectionName, CreatorID, CategoryID)
            OUTPUT INSERTED.CollectionID
            VALUES (?, ?, ?)
        """, (collection.CollectionName, collection.CreatorID, collection.CategoryID))
        
        # Fetch the newly created CollectionID
        collection_id = cursor.fetchone()[0]
        
        conn.commit()
        return {"message": "Collection created successfully", "collection_id": collection_id}
            
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@app.post("/api/categories")
async def create_category(category: CategoryCreate):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Check if category name already exists
        cursor.execute("SELECT CategoryID FROM Categories WHERE CategoryName = ?", (category.CategoryName,))
        if cursor.fetchone():
            raise HTTPException(status_code=400, detail="Category with this name already exists")

        cursor.execute("""
            INSERT INTO Categories (CategoryName)
            OUTPUT INSERTED.CategoryID
            VALUES (?)
        """, (category.CategoryName,))
        
        new_category_id = cursor.fetchone()[0]
        conn.commit()
        return {"message": "Category created successfully", "category_id": new_category_id}
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error creating category: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
