# MetaMood NFT Marketplace

A web-based NFT marketplace built with FastAPI and SQL Server.

## Features

- User authentication (login/register)
- NFT creation and management
- Collection management
- Wallet functionality
- Bidding system
- Reporting system
- Category management

## Technologies Used

- **Backend**: Python, FastAPI
- **Database**: SQL Server
- **Frontend**: HTML, CSS, JavaScript
- **Templates**: Jinja2

## Setup Instructions

1. Clone the repository
2. Create a virtual environment:
   ```
   python -m venv venv
   ```
3. Activate the virtual environment:
   - Windows: `venv\Scripts\activate`
   - Unix/MacOS: `source venv/bin/activate`
4. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
5. Set up the database:
   - Create a SQL Server database named 'METAMOOD'
   - Run the SQL script in `metamood_tables.sql`
6. Update database connection settings in `main.py`
7. Run the application:
   ```
   uvicorn main:app --reload
   ```

## Project Structure

- `main.py` - Main application file
- `metamood_tables.sql` - Database schema
- `templates/` - HTML templates
- `static/` - Static files (CSS, JavaScript, images)

## API Endpoints

- `/api/nfts` - NFT management
- `/api/collections` - Collection management
- `/api/users` - User management
- `/api/wallet` - Wallet operations
- `/api/bids` - Bidding system
- `/api/reports` - Reporting system

## Author

Daniyal
Muhammad Atif

## License

This project is licensed under the MIT License. 