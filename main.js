console.log('Script loaded and running.');

// API endpoints
const API_URL = 'http://localhost:8000';

// Fetch NFTs from the backend
async function fetchNFTs() {
    try {
        const response = await fetch(`${API_URL}/api/nfts`);
        const nfts = await response.json();
        displayNFTs(nfts);
    } catch (error) {
        console.error('Error fetching NFTs:', error);
    }
}

// Display NFTs in the grid
function displayNFTs(nfts) {
    const nftGrid = document.getElementById('nftGrid');
    if (!nftGrid) return;
    nftGrid.innerHTML = '';

    nfts.forEach(nft => {
        const nftCard = document.createElement('div');
        nftCard.className = 'nft-card';

        const nftLink = document.createElement('a');
        nftLink.href = `/nfts/${nft.NFTID}`;
        nftLink.className = 'nft-card-link';

        nftLink.innerHTML = `
            <div class="nft-card-image">
                <img src="/static/images/placeholder.jpg" alt="${nft.Title}">
            </div>
            <div class="nft-card-content">
                <h3 class="nft-card-title">${nft.Title}</h3>
                <p class="nft-card-description">${nft.Description}</p>
                <div class="nft-card-footer">
                    <span class="nft-card-owner">Owner ID: ${nft.OwnerID}</span>
                    <span class="nft-card-id">#${nft.NFTID}</span>
                </div>
            </div>
        `;
        
        nftCard.appendChild(nftLink);
        nftGrid.appendChild(nftCard);
    });
}

// Fetch Collections from the backend
async function fetchCollections() {
    try {
        const response = await fetch(`${API_URL}/api/collections`);
        const collections = await response.json();
        displayCollections(collections);
    } catch (error) {
        console.error('Error fetching collections:', error);
    }
}

// Display Collections in a list or grid
function displayCollections(collections) {
    const collectionList = document.getElementById('collectionList');
    if (!collectionList) return;
    
    collectionList.innerHTML = '';
    
    collections.forEach(collection => {
        const collectionItem = document.createElement('div');
        collectionItem.className = 'collection-item';
        collectionItem.innerHTML = `
            <h3>${collection.CollectionName}</h3>
            <div class="collection-meta">
                <span class="collection-creator">Creator ID: ${collection.CreatorID}</span>
                ${collection.CategoryID ? `<span class="collection-category">Category ID: ${collection.CategoryID}</span>` : ''}
            </div>
        `;
        collectionList.appendChild(collectionItem);
    });
}

// Fetch reports from the backend
async function fetchReports() {
    try {
        const response = await fetch(`${API_URL}/api/reports`);
        const reports = await response.json();
        displayReports(reports);
    } catch (error) {
        console.error('Error fetching reports:', error);
        const reportsListDiv = document.getElementById('reportsList');
         if (reportsListDiv) {
            reportsListDiv.innerHTML = '<p>Error loading reports.</p>';
        }
    }
}

// Display reports in the list
function displayReports(reports) {
    const reportsListDiv = document.getElementById('reportsList');
    if (!reportsListDiv) return; // Exit if div doesn't exist
    reportsListDiv.innerHTML = ''; // Clear existing content

    if (reports.length === 0) {
        reportsListDiv.innerHTML = '<p>No reports found.</p>';
        return;
    }

    reports.forEach(report => {
        const reportItem = document.createElement('div');
        reportItem.className = 'report-item'; // Add a class for styling
        reportItem.innerHTML = `
            <p><strong>Report ID:</strong> ${report.ReportID}</p>
            <p><strong>Reported By:</strong> ${report.ReporterUsername}</p>
            <p><strong>Reported NFT:</strong> ${report.NFTTitle}</p>
            <p><strong>Reason:</strong> ${report.Reason || 'No reason provided'}</p>
            <p><strong>Reported At:</strong> ${new Date(report.ReportedAt).toLocaleString()}</p>
            <hr>
        `;
        reportsListDiv.appendChild(reportItem);
    });
}

// Handle any form submission
document.body.addEventListener('submit', async (event) => {
    console.log('Form submit event captured on body.');
    const form = event.target;
    console.log('Submitted form ID:', form.id);

    // Handle login form submission
    if (form.id === 'loginForm') {
        console.log('Handling login form submit...');
        event.preventDefault(); // Prevent default form submission for login form
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        try {
            const response = await fetch(`${API_URL}/api/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data),
            });

            const result = await response.json();

            if (response.ok) {
                // Store user_id in localStorage
                localStorage.setItem('user_id', result.user_id);
                // Redirect to the user's wallet page
                window.location.href = `/users/${result.user_id}/wallet`;
            } else {
                alert(`Login failed: ${result.detail || response.statusText}`);
                console.error('Login error:', result);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An unexpected error occurred during login.');
        }
    }
    // Handle registration form submission
    else if (form.id === 'registrationForm') {
         console.log('Handling registration form submit...');
         event.preventDefault(); // Prevent default form submission for registration form
         const formData = new FormData(form);
         const data = Object.fromEntries(formData.entries());

         try {
             const response = await fetch(`${API_URL}/api/register`, {
                 method: 'POST',
                 headers: {
                     'Content-Type': 'application/json',
                 },
                 body: JSON.stringify(data),
             });

             const result = await response.json();

             if (response.ok) {
                 // Store user_id in localStorage
                 localStorage.setItem('user_id', result.user_id);
                 // Redirect to the user's wallet page after registration
                 window.location.href = `/users/${result.user_id}/wallet`;
             } else {
                 alert(`Registration failed: ${result.detail || response.statusText}`);
                 console.error('Registration error:', result);
             }
         } catch (error) {
             console.error('Error:', error);
             alert('An unexpected error occurred during registration.');
         }
    }
    // Handle report form submission
    else if (form.id === 'reportForm') {
         console.log('Handling report form submit...');
         event.preventDefault(); // Prevent default form submission for report form
         const formData = new FormData(form);
         const data = Object.fromEntries(formData.entries());

         // Convert NFTID to number
         data.NFTID = parseInt(data.NFTID);

         // Basic validation (more robust validation should be on backend too)
         if (isNaN(data.NFTID)) {
             alert('Please enter a valid number for NFT ID.');
             return;
         }

         try {
             const response = await fetch(`${API_URL}/api/reports`, {
                 method: 'POST',
                 headers: {
                     'Content-Type': 'application/json',
                 },
                 body: JSON.stringify(data),
             });

             const result = await response.json();

             if (response.ok) {
                 alert('Report submitted successfully!');
                 form.reset(); // Clear the form
                 fetchReports(); // Refresh the list of reports
             } else {
                 alert(`Failed to submit report: ${result.detail || response.statusText}`);
                 console.error('Report submission error:', result);
             }
         } catch (error) {
             console.error('Error:', error);
             alert('An unexpected error occurred during report submission.');
         }
    }
    // Add more form handlers here if needed
});

// Fetch wallet details for a user
async function fetchWalletDetails(userId) {
    try {
        const response = await fetch(`${API_URL}/api/users/${userId}/wallet`);
        const wallet = await response.json();
        displayWalletDetails(wallet);
    } catch (error) {
        console.error(`Error fetching wallet for user ${userId}:`, error);
        const walletDetailsDiv = document.getElementById('walletDetails');
        if (walletDetailsDiv) {
            walletDetailsDiv.innerHTML = '<p>Error loading wallet details.</p>';
        }
    }
}

// Display wallet details on the page
function displayWalletDetails(wallet) {
    const walletDetailsDiv = document.getElementById('walletDetails');
    if (!walletDetailsDiv) return; // Exit if div doesn't exist

    walletDetailsDiv.innerHTML = `
        <p><strong>Wallet ID:</strong> ${wallet.WalletID}</p>
        <p><strong>User ID:</strong> ${wallet.UserID}</p>
        <p><strong>Public Key:</strong> ${wallet.PublicKey}</p>
        <p><strong>Balance:</strong> ${wallet.Balance.toFixed(2)}</p>
    `;
}

// Fetch Categories from the backend and display them
async function fetchCategories() {
    try {
        const response = await fetch(`${API_URL}/api/categories`);
        const categories = await response.json();
        displayCategories(categories);
    } catch (error) {
        console.error('Error fetching categories:', error);
    }
}

// Display Categories in a list or grid
function displayCategories(categories) {
    const categoriesList = document.getElementById('categoriesList');
    if (!categoriesList) return; // Exit if categoriesList doesn't exist
    
    categoriesList.innerHTML = ''; // Clear existing items

    categories.forEach(category => {
        const categoryItem = document.createElement('li');
        categoryItem.className = 'category-item'; // Use a new class for styling
        categoryItem.innerHTML = `
            <h4>${category.CategoryName}</h4>
            <!-- Add more category details if needed -->
        `;
        categoriesList.appendChild(categoryItem);
    });
}

// Category creation form handling
document.getElementById('createCategoryBtn')?.addEventListener('click', () => {
    const form = document.getElementById('createCategoryForm');
    form.style.display = 'block';
});

document.getElementById('cancelCategoryBtn')?.addEventListener('click', () => {
    const form = document.getElementById('createCategoryForm');
    form.style.display = 'none';
    document.getElementById('categoryForm').reset();
});

document.getElementById('categoryForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const categoryName = document.getElementById('categoryName').value;

    try {
        const response = await fetch(`${API_URL}/api/categories`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ CategoryName: categoryName })
        });

        const data = await response.json();
        
        if (response.ok) {
            alert('Category created successfully!');
            document.getElementById('createCategoryForm').style.display = 'none';
            document.getElementById('categoryForm').reset();
            fetchCategories(); // Refresh the categories list
        } else {
            alert(data.detail || 'Failed to create category');
        }
    } catch (error) {
        console.error('Error creating category:', error);
        alert('An error occurred during category creation');
    }
});

// Initial data fetching based on the current page
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM fully loaded and parsed');
    if (document.getElementById('nftGrid')) {
        console.log('Homepage detected, fetching NFTs.');
        fetchNFTs();
    } else if (document.getElementById('collectionList')) {
        console.log('Collections page detected, fetching collections.');
        fetchCollections();
    } else if (document.getElementById('reportsList')) {
        console.log('Reports page detected, fetching reports.');
        fetchReports();
    } else if (document.getElementById('walletDetails')) {
         console.log('Wallet page detected, fetching wallet details.');
         // We need the user ID for this. In a real app, you'd get this from a session.
         // For now, we might hardcode it or get it from the URL if the wallet page URL includes it.
         // Assuming the URL is like /users/{user_id}/wallet
         const pathSegments = window.location.pathname.split('/');
         const userId = pathSegments[2]; // Assuming the structure /users/user_id/wallet
         if (userId) {
             fetchWalletDetails(userId);
         } else {
             console.error('User ID not found in URL for wallet page.');
             const walletDetailsDiv = document.getElementById('walletDetails');
             if (walletDetailsDiv) {
                 walletDetailsDiv.innerHTML = '<p>Error: User ID not found.</p>';
             }
         }
    } else if (document.getElementById('categoriesList')) { // Add condition for Categories page
         console.log('Categories page detected, fetching categories.');
         fetchCategories();
    }
    // Add more page-specific initial fetches here
});

// New function to fetch and display bids for a specific NFT
async function fetchAndDisplayBids(nftId) {
    console.log(`Fetching and displaying bids for NFT ID: ${nftId}`);
    try {
        const response = await fetch(`${API_URL}/api/nfts/${nftId}/bids`);
        console.log('Fetch bids response status:', response.status);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const bids = await response.json();
        console.log('Fetched bids data:', bids);

        const bidsListElement = document.querySelector('.nft-bids ul'); // Select the unordered list for bids
        const bidsSectionElement = document.querySelector('.nft-bids'); // Select the entire bids section

        if (!bidsListElement) {
            console.log('Bids list element not found.');
            return; // Exit if the bids list element doesn't exist
        }

        bidsListElement.innerHTML = ''; // Clear existing bids

        if (bids.length === 0) {
             // If no bids, hide the bids section or show a message
            if(bidsSectionElement) bidsSectionElement.style.display = 'none';
            console.log('No bids found, hiding section.');
            return;
        } else {
             if(bidsSectionElement) bidsSectionElement.style.display = 'block'; // Show the section if there are bids
             console.log(`Displaying ${bids.length} bids.`);
        }

        bids.forEach(bid => {
            const bidItem = document.createElement('li');
            bidItem.innerHTML = `<strong>${bid.BidderUsername}</strong> bid ${bid.BidAmount} at ${new Date(bid.BidAt).toLocaleString()}`;
            bidsListElement.appendChild(bidItem);
        });

    } catch (error) {
        console.error(`Error fetching bids for NFT ${nftId}:`, error);
        const bidsListElement = document.querySelector('.nft-bids ul');
        if (bidsListElement) {
            bidsListElement.innerHTML = '<li>Error loading bids.</li>';
        }
         const bidsSectionElement = document.querySelector('.nft-bids');
         if(bidsSectionElement) bidsSectionElement.style.display = 'block'; // Show section with error message
    }
}

// Add a specific event listener for the bid form after the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOMContentLoaded fired.');
    const bidForm = document.getElementById('bidForm');
    if (bidForm) {
        console.log('Bid form found, attaching listener.');
        bidForm.addEventListener('submit', async (event) => {
            console.log('Handling bid form submit (specific listener)...');
            event.preventDefault(); // Prevent default form submission
            
            const formData = new FormData(bidForm);
            const data = Object.fromEntries(formData.entries());

            // Convert data types to match backend expected types (int for NFTID, float for amount)
            data.NFTID = parseInt(data.NFTID);
            // Correctly get BidderUsername from form data
            data.BidderUsername = data.BidderUsername; // This now gets the value from the input with name='BidderUsername'

            data.BidAmount = parseFloat(data.BidAmount);

            // Basic validation
            // Update validation to check for BidderUsername (string) and BidAmount (number > 0)
            if (isNaN(data.NFTID) || typeof data.BidderUsername !== 'string' || data.BidderUsername.trim() === '' || isNaN(data.BidAmount) || data.BidAmount <= 0) {
                alert('Please enter a valid Username, Bid Amount, and ensure Bid Amount is positive.');
                return;
            }

            try {
                const response = await fetch(`${API_URL}/api/bids`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(data),
                });

                const result = await response.json();
                const bidMessageElement = document.getElementById('bidMessage');

                if (response.ok) {
                    if (bidMessageElement) {
                        bidMessageElement.textContent = result.message; // Display success message
                        bidMessageElement.style.color = 'green';
                    }
                    bidForm.reset(); // Clear the form
                    // **Refresh the bids list after successful submission**
                    const nftIdInput = document.querySelector('input[name="NFTID"]');
                    if (nftIdInput && nftIdInput.value) {
                        fetchAndDisplayBids(parseInt(nftIdInput.value));
                    }
                } else {
                    if (bidMessageElement) {
                        bidMessageElement.textContent = `Failed to place bid: ${result.detail || response.statusText}`; // Display error message
                        bidMessageElement.style.color = 'red';
                    }
                    console.error('Bid submission error:', result);
                }
            } catch (error) {
                console.error('Error:', error);
                if (bidMessageElement) {
                    bidMessageElement.textContent = 'An unexpected error occurred during bid submission.';
                    bidMessageElement.style.color = 'red';
                }
            }
        });
    } else {
        console.log('Bid form not found on DOMContentLoaded.');
    }

    // **Fetch and display bids when the NFT detail page loads**
    // Check if we are on an NFT detail page by looking for the bid form or bids section
    const nftDetailContainer = document.querySelector('.nft-detail');
    const currentPath = window.location.pathname;
    if (nftDetailContainer && currentPath.startsWith('/nfts/')) {
        // Extract NFT ID from the URL
        const pathSegments = currentPath.split('/');
        const nftId = parseInt(pathSegments[pathSegments.length - 1]);

        if (!isNaN(nftId)) {
            fetchAndDisplayBids(nftId);
        }
    }
});

// Function to update navigation links with user_id
function updateNavigationLinks() {
    const user_id = localStorage.getItem('user_id');
    if (user_id) {
        // Update all navigation links to include user_id
        const navLinks = document.querySelectorAll('.nav-links a');
        navLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href && !href.includes('user_id=') && !href.includes('/login') && !href.includes('/register')) {
                link.href = `${href}?user_id=${user_id}`;
            }
        });
    }
}

// Call updateNavigationLinks when the page loads
document.addEventListener('DOMContentLoaded', updateNavigationLinks);

// Collection creation form handling
document.getElementById('createCollectionBtn')?.addEventListener('click', () => {
    const form = document.getElementById('createCollectionForm');
    form.style.display = 'block';
    loadCategories(); // Load categories for the dropdown
});

document.getElementById('cancelCollectionBtn')?.addEventListener('click', () => {
    const form = document.getElementById('createCollectionForm');
    form.style.display = 'none';
    form.reset();
});

// Load categories for the collection form
async function loadCategories() {
    try {
        const response = await fetch(`${API_URL}/api/categories`);
        const categories = await response.json();
        const categorySelect = document.getElementById('collectionCategory');
        
        // Clear existing options except the first one
        while (categorySelect.options.length > 1) {
            categorySelect.remove(1);
        }
        
        // Add new options
        categories.forEach(category => {
            const option = document.createElement('option');
            option.value = category.CategoryID;
            option.textContent = category.CategoryName;
            categorySelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

// Handle collection form submission
document.getElementById('collectionForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const user_id = localStorage.getItem('user_id');
    if (!user_id) {
        alert('You must be logged in to create a collection');
        return;
    }
    
    const collectionData = {
        CollectionName: document.getElementById('collectionName').value,
        CreatorID: parseInt(user_id),
        CategoryID: document.getElementById('collectionCategory').value || null,
    };
    
    try {
        const response = await fetch(`${API_URL}/api/collections`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(collectionData)
        });
        
        if (response.ok) {
            alert('Collection created successfully!');
            document.getElementById('createCollectionForm').style.display = 'none';
            document.getElementById('collectionForm').reset();
            fetchCollections(); // Refresh the collections list
        } else {
            const error = await response.json();
            alert(error.detail || 'Failed to create collection');
        }
    } catch (error) {
        console.error('Error creating collection:', error);
        alert('An error occurred while creating the collection');
    }
}); 