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

        // Generate a unique seed based on NFT properties
        const imageUrl = '/static/images/placeholder.jpg';

        nftLink.innerHTML = `
            <div class="nft-card-image">
                <img src="${imageUrl}" alt="${nft.Title}">
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
    // Handle create NFT form submission
    else if (form.id === 'createNftForm') {
        console.log('Handling create NFT form submit...');
        event.preventDefault(); // Prevent default form submission

        const title = form.querySelector('#Title').value;
        const description = form.querySelector('#Description').value;
        const ownerId = localStorage.getItem('user_id');
        const collectionSelect = form.querySelector('#collection');
        const collectionId = collectionSelect ? (collectionSelect.value || null) : null;

        if (!ownerId) {
            alert('Owner ID not found. Please log in.');
            return;
        }

        const nftData = {
            Title: title,
            Description: description,
            OwnerID: parseInt(ownerId),
            CollectionID: collectionId ? parseInt(collectionId) : null,
        };

        try {
            const response = await fetch(`${API_URL}/nfts`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(nftData),
            });

            const result = await response.json();

            if (response.ok) {
                alert('NFT created successfully!');
                window.location.href = `/nfts?user_id=${ownerId}`;
            } else {
                let errorMessage = `Failed to create NFT: ${response.status} ${response.statusText}.`;
                if (result && typeof result === 'object' && result.detail) {
                    if (typeof result.detail === 'string') {
                        errorMessage = `Failed to create NFT: ${result.detail}`;
                    } else if (Array.isArray(result.detail) && result.detail.length > 0) {
                        errorMessage = `Failed to create NFT: ${result.detail.map(err => err.msg).join(', ')}`;
                    }
                }
                alert(errorMessage);
                console.error('NFT creation error:', result, response);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An unexpected error occurred during NFT creation.');
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
    // Handle bid form submission
    else if (form.id === 'bidForm') {
        console.log('Handling bid form submit...');
        event.preventDefault(); // Prevent default form submission

        const nftId = form.querySelector('input[name="NFTID"]').value;
        const bidAmount = form.querySelector('#bidAmount').value;
        const bidderUsername = form.querySelector('#bidderId').value; // Get username from input
        const bidMessageElement = document.getElementById('bidMessage');

        if (!bidderUsername) {
            bidMessageElement.textContent = 'Please enter your username.';
            bidMessageElement.style.color = 'red';
            return;
        }

        const bidData = {
            NFTID: parseInt(nftId),
            BidAmount: parseFloat(bidAmount),
            BidderUsername: bidderUsername // Send username to backend
        };

        try {
            const response = await fetch(`${API_URL}/api/bids`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(bidData),
            });

            const result = await response.json();

            if (response.ok) {
                bidMessageElement.textContent = 'Bid placed successfully!';
                bidMessageElement.style.color = 'green';
                form.reset(); // Clear the form
                fetchAndDisplayBids(nftId); // Refresh the list of bids
            } else {
                let errorMessage = `Failed to place bid: ${response.status} ${response.statusText}.`;
                if (result && result.detail) {
                    errorMessage = `Failed to place bid: ${result.detail}`;
                }
                bidMessageElement.textContent = errorMessage;
                bidMessageElement.style.color = 'red';
                console.error('Bid submission error:', result);
            }
        } catch (error) {
            console.error('Error:', error);
            bidMessageElement.textContent = 'An unexpected error occurred during bid submission.';
            bidMessageElement.style.color = 'red';
         }
    }
    // Add more form handlers here if needed
});

// Fetch wallet details for a user
async function fetchWalletDetails(userId) {
    console.log(`Attempting to fetch wallet details for user ID: ${userId}...`);
    try {
        const response = await fetch(`${API_URL}/api/users/${userId}/wallet`);
        console.log('Wallet API response status:', response.status);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const wallet = await response.json();
        console.log('Fetched wallet data:', wallet);
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
    if (!walletDetailsDiv) {
        console.log('walletDetails element not found, cannot display wallet.');
        return; 
    }
    console.log('Displaying wallet details...', wallet);

    walletDetailsDiv.innerHTML = `
        <p><strong>Wallet ID:</strong> ${wallet.WalletID}</p>
        <p><strong>User ID:</strong> ${wallet.UserID}</p>
        <p><strong>Public Key:</strong> ${wallet.PublicKey}</p>
        <p><strong>Balance:</strong> ${wallet.Balance.toFixed(2)}</p>
    `;
}

// Fetch Categories from the backend and display them
async function fetchCategories() {
    console.log('Attempting to fetch categories...');
    try {
        const response = await fetch(`${API_URL}/api/categories`);
        console.log('Categories API response status:', response.status);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const categories = await response.json();
        console.log('Fetched categories data:', categories);
        displayCategories(categories);
    } catch (error) {
        console.error('Error fetching categories:', error);
         const categoriesList = document.getElementById('categoriesList');
         if (categoriesList) {
            categoriesList.innerHTML = '<p>Error loading categories.</p>';
        }
    }
}

// Display Categories in a list or grid
function displayCategories(categories) {
    const categoriesList = document.getElementById('categoriesList');
    if (!categoriesList) {
        console.log('categoriesList element not found, cannot display categories.');
        return;
    } 
    console.log('Displaying categories...', categories);
    
    categoriesList.innerHTML = ''; // Clear existing items

    if (categories.length === 0) {
        categoriesList.innerHTML = '<p>No categories found.</p>';
        console.log('No categories found to display.');
        return;
    }

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

// Handle category creation
document.addEventListener('DOMContentLoaded', () => {
    const createCategoryBtn = document.getElementById('createCategoryBtn');
    const createCategoryForm = document.getElementById('createCategoryForm');
    const cancelCategoryBtn = document.getElementById('cancelCategoryBtn');
    const categoryForm = document.getElementById('categoryForm');

    if (createCategoryBtn && createCategoryForm && cancelCategoryBtn && categoryForm) {
        // Show form when Create Category button is clicked
        createCategoryBtn.addEventListener('click', () => {
            createCategoryForm.style.display = 'block';
        });

        // Hide form when Cancel button is clicked
        cancelCategoryBtn.addEventListener('click', () => {
            createCategoryForm.style.display = 'none';
        });

        // Handle form submission
        categoryForm.addEventListener('submit', async (event) => {
            event.preventDefault();
            const categoryName = document.getElementById('categoryName').value;
            const userId = localStorage.getItem('user_id');

            if (!userId) {
                alert('Please log in to create a category.');
                return;
            }

            try {
                const response = await fetch(`${API_URL}/api/categories`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        CategoryName: categoryName,
                        CreatorID: parseInt(userId)
                    }),
                });

                const result = await response.json();

                if (response.ok) {
                    alert('Category created successfully!');
                    createCategoryForm.style.display = 'none';
                    categoryForm.reset();
                    // Refresh the categories list
                    fetchCategories();
                } else {
                    alert(`Failed to create category: ${result.detail || response.statusText}`);
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An unexpected error occurred while creating the category.');
            }
        });
    }
});

// Load collections into the dropdown
async function loadCollectionsForDropdown() {
    try {
        const response = await fetch(`${API_URL}/api/collections`);
        const collections = await response.json();
        const collectionSelect = document.getElementById('collection');
        
        if (collectionSelect) {
            // Clear existing options except the first "None" option
            while (collectionSelect.options.length > 1) {
                collectionSelect.remove(1);
            }
            
            // Add collections to dropdown
            collections.forEach(collection => {
                const option = document.createElement('option');
                option.value = collection.CollectionID;
                option.textContent = collection.CollectionName;
                collectionSelect.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading collections for dropdown:', error);
    }
}

// Call appropriate functions when the page loads
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM fully loaded');
    
    // Load NFTs if on the NFTs page
    if (document.getElementById('nftGrid')) {
        fetchNFTs();
    }
    
    // Load collections if on the collections page
    if (document.getElementById('collectionList')) {
        fetchCollections();
    }
    
    // Load reports if on the reports page
    if (document.getElementById('reportsList')) {
        fetchReports();
    }
    
    // Load categories if on the categories page
    if (document.getElementById('categoriesList')) {
        fetchCategories();
    }

    // Load wallet details if on the wallet page
    if (document.getElementById('walletDetails')) {
         const pathSegments = window.location.pathname.split('/');
        // Assuming URL structure /users/{user_id}/wallet
        const userId = pathSegments[2]; 
         if (userId) {
             fetchWalletDetails(userId);
         } else {
            console.error('User ID not found in URL for wallet page. Cannot fetch wallet details.');
             const walletDetailsDiv = document.getElementById('walletDetails');
             if (walletDetailsDiv) {
                walletDetailsDiv.innerHTML = '<p>Error: User ID not found to display wallet details.</p>';
            }
        }
    }
    
    // Load collections for NFT form dropdown
    if (document.getElementById('collection')) {
        loadCollectionsForDropdown();
    }
    
    // Update navigation links
    updateNavigationLinks();
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
            bidsListElement.innerHTML = '<p>Error loading bids.</p>';
        }
    }
}

// Call fetchAndDisplayBids when the nft_detail page loads
document.addEventListener('DOMContentLoaded', () => {
    const nftDetailElement = document.querySelector('.nft-detail');
    if (nftDetailElement) {
        // Extract NFT ID from the URL or a data attribute
        const pathParts = window.location.pathname.split('/');
        const nftId = pathParts[pathParts.length - 1]; // Assumes URL is /nfts/{nftId}
        if (nftId && !isNaN(nftId)) {
            fetchAndDisplayBids(parseInt(nftId));
        }
    }
}); 
