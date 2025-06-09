USE MetaMood;


CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);



CREATE TABLE Wallets (
    WalletID INT PRIMARY KEY IDENTITY,
    UserID INT NOT NULL,
    PublicKey VARCHAR(200) UNIQUE NOT NULL,
    Balance DECIMAL(18, 2) DEFAULT 0.00,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


CREATE TABLE NFTs (
    NFTID INT PRIMARY KEY IDENTITY,
    Title VARCHAR(100) NOT NULL,
    Description TEXT,
    CollectionID INT,
    OwnerID INT NOT NULL,
    MintedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CollectionID) REFERENCES Collections(CollectionID),
    FOREIGN KEY (OwnerID) REFERENCES Users(UserID)
);


CREATE TABLE Collections (
    CollectionID INT PRIMARY KEY IDENTITY,
    CollectionName VARCHAR(100) NOT NULL,
    CreatorID INT NOT NULL,
    CategoryID INT,
    FOREIGN KEY (CreatorID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE Tags (
    TagID INT PRIMARY KEY IDENTITY,
    TagName VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE NFT_Tags (
    NFTID INT NOT NULL,
    TagID INT NOT NULL,
    PRIMARY KEY (NFTID, TagID),
    FOREIGN KEY (NFTID) REFERENCES NFTs(NFTID),
    FOREIGN KEY (TagID) REFERENCES Tags(TagID)
);


CREATE TABLE Listings (
    ListingID INT PRIMARY KEY IDENTITY,
    NFTID INT NOT NULL UNIQUE,
    SellerID INT NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    ListedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (NFTID) REFERENCES NFTs(NFTID),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);
CREATE TABLE Bids (
    BidID INT PRIMARY KEY IDENTITY,
    ListingID INT NOT NULL,
    BidderID INT NOT NULL,
    BidAmount DECIMAL(18, 2) NOT NULL,
    BidAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ListingID) REFERENCES Listings(ListingID),
    FOREIGN KEY (BidderID) REFERENCES Users(UserID)
);
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY,
    NFTID INT NOT NULL,
    BuyerID INT NOT NULL,
    SellerID INT NOT NULL,
    SalePrice DECIMAL(18, 2) NOT NULL,
    TransactionDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (NFTID) REFERENCES NFTs(NFTID),
    FOREIGN KEY (BuyerID) REFERENCES Users(UserID),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);
CREATE TABLE Royalties (
    NFTID INT PRIMARY KEY,
    CreatorID INT NOT NULL,
    Percentage DECIMAL(5, 2) NOT NULL,
    FOREIGN KEY (NFTID) REFERENCES NFTs(NFTID),
    FOREIGN KEY (CreatorID) REFERENCES Users(UserID)
);
CREATE TABLE Likes (
    UserID INT NOT NULL,
    NFTID INT NOT NULL,
    LikedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (UserID, NFTID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (NFTID) REFERENCES NFTs(NFTID)
);
CREATE TABLE Reports (
    ReportID INT PRIMARY KEY IDENTITY,
    ReporterID INT NOT NULL,
    NFTID INT NOT NULL,
    Reason VARCHAR(255),
    ReportedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ReporterID) REFERENCES Users(UserID),
    FOREIGN KEY (NFTID) REFERENCES NFTs(NFTID)
);
CREATE TABLE Favorites (
    UserID INT NOT NULL,
    CollectionID INT NOT NULL,
    FavoritedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (UserID, CollectionID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CollectionID) REFERENCES Collections(CollectionID)
);
CREATE TABLE NFT_Views (
    ViewID INT PRIMARY KEY IDENTITY,
    NFTID INT NOT NULL,
    ViewerID INT NOT NULL,
    ViewedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (NFTID) REFERENCES NFTs(NFTID),
    FOREIGN KEY (ViewerID) REFERENCES Users(UserID)
);

INSERT INTO Users (Username, Email, CreatedAt) VALUES ('zara_javed50', 'zara.javed207@gmail.com', '2025-04-27 15:30:26');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('ali_ahmed22', 'ali.ahmed87@gmail.com', '2025-05-15 08:25:25');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('usman_raza33', 'usman.raza976@gmail.com', '2025-06-04 01:02:46');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('usman_khan4', 'usman.khan775@gmail.com', '2025-04-10 03:23:20');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('bilal_chaudhry54', 'bilal.chaudhry598@gmail.com', '2025-04-14 23:38:26');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('fatima_hussain37', 'fatima.hussain836@gmail.com', '2025-05-06 15:46:48');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('zara_qureshi43', 'zara.qureshi314@gmail.com', '2025-05-28 13:09:36');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('amna_javed96', 'amna.javed324@gmail.com', '2025-05-27 06:39:39');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('fatima_malik57', 'fatima.malik194@gmail.com', '2025-04-16 12:57:57');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('amna_hussain31', 'amna.hussain216@gmail.com', '2025-05-08 22:24:34');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('zara_malik20', 'zara.malik794@gmail.com', '2025-05-20 17:34:34');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('ahsan_chaudhry25', 'ahsan.chaudhry435@gmail.com', '2025-05-01 08:18:31');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('fatima_khan79', 'fatima.khan605@gmail.com', '2025-04-08 20:47:46');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('zara_javed61', 'zara.javed930@gmail.com', '2025-04-20 01:48:58');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('amna_khan45', 'amna.khan261@gmail.com', '2025-04-07 16:06:41');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('bilal_raza10', 'bilal.raza497@gmail.com', '2025-05-06 08:13:03');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('usman_javed5', 'usman.javed397@gmail.com', '2025-04-26 12:19:11');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('fatima_khan97', 'fatima.khan765@gmail.com', '2025-05-11 19:26:55');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('mariam_malik48', 'mariam.malik979@gmail.com', '2025-04-30 05:36:13');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('noor_javed90', 'noor.javed520@gmail.com', '2025-04-20 20:56:39');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('fatima_raza61', 'fatima.raza289@gmail.com', '2025-05-26 13:21:59');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('amna_khan96', 'amna.khan924@gmail.com', '2025-05-15 10:01:11');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('fatima_malik56', 'fatima.malik439@gmail.com', '2025-04-16 16:10:28');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('zara_chaudhry30', 'zara.chaudhry777@gmail.com', '2025-05-10 00:01:43');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('amna_malik66', 'amna.malik356@gmail.com', '2025-04-13 05:27:10');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('usman_raza78', 'usman.raza361@gmail.com', '2025-04-24 13:32:17');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('noor_siddiqui1', 'noor.siddiqui263@gmail.com', '2025-04-18 19:11:51');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('ahsan_khan60', 'ahsan.khan241@gmail.com', '2025-05-05 14:35:50');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('usman_khan28', 'usman.khan742@gmail.com', '2025-04-21 01:10:11');
INSERT INTO Users (Username, Email, CreatedAt) VALUES ('bilal_sheikh49', 'bilal.sheikh695@gmail.com', '2025-05-24 17:20:48');

SELECT * FROM Users;


INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (1, '0xA1F6C3D7E0F1B45A9D34E7A6B45F4C8A11A63A21', 1532.75);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (2, '0xB9D1A45C9E2B376AA3D5F1C478B349C1EF55C92B', 204.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (3, '0xC4A7D52E1F0E43B7C6A51E1F9D7C2E86AA3E3AC5', 9250.10);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (4, '0xD3B5E49A7614F6C4D1A2B85E0F9B99F4C8B3D2EA', 385.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (5, '0xE47C9B2F67A2E3C45A1B9E54A7C62A93DD1C7E20', 800.60);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (6, '0xF123C4B5D90B7E8A1D23F0C6492B3D58A8C3C2F7', 3001.99);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (7, '0xA9F0D2C4785A3B4D1A2F91B3E67C9A3E11B0F8B4', 112.75);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (8, '0xB4C7A3F19E2A45F0C3A9D1C874F3B2A7DD7A49C3', 570.15);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (9, '0xC8D9E54B71F8C3A2B4D3F7E9A16B2D7F8C9D3A1A', 4000.25);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (10, '0xD7A3B1F2C49E1A3D5F7B9C0D8A2B3F91A63B2C7A', 920.80);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (11, '0xE1F9C3B7A5D0F4B2E3A9B5C74D8F1C0D43A6C1E3', 1287.90);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (12, '0xF7B4E3C9A2D0C1B3E5A9C7F81D4B3A8C19D3E2F9', 248.65);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (13, '0xA2F9C1B3E6A5D4B2C3F7E8A9D10C4B8A23E1C5D3', 3645.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (14, '0xB6C8D7F2A3E9B4C1F0D2A5E8C19B3F7D5A3C2E1F', 1020.50);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (15, '0xC3B7A1D9E2F0C5A8B4E1F3A6D7B9C0F1A23B5C9D', 73.40);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (16, '0xD9A2F1B0C3E5D7A6F4C8B3E1A5F2C7B9D8E1A3C0', 999.99);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (17, '0xE8F7A2C3B9D1C4F6A3B0E7D9F1C2A5B3C9D4A2F1', 120.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (18, '0xF1D2B3E0A4C9D7B2F8A3E6B1C0F4D9A7B3C2E9F4', 480.20);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (19, '0xA3E1C2B4D5F7A9C0F6D8B1A2C3E9B7F4D1C8A0F2', 230.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (20, '0xB0D7F3A1C2E8B4D5F9C6A3B0E1C7D2F8A9B3C5E1', 0.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (21, '0xC1F9E7B2A3D0C8B5F1E2D4A9B3F7C0D1A6B2E9F3', 58.30);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (22, '0xD2A3F9B1C0E7D4F3B9A6C1F5E8D0B3A2C7F4E1D9', 1480.70);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (23, '0xE3C9F0D2A7B4C6E8F5A3D1B0C9E7A4B3F1C6D9E0', 312.44);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (24, '0xF4B8A2C1E9D7F3B0C6A4E1F8D2C3B9A5E7F0D1C2', 845.10);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (25, '0xA0F2C9B7D3E1A5F8C4B6D0E3A9C1F7B2E8D4C3A1', 512.89);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (26, '0xB1E9A3C0D7F5C6A4B8F1D2E0C3A9F7B1E6C4D2F0', 330.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (27, '0xC2D0F1B3A9C6E4D7B5F0A2C3E1D9F8B4A6C0E7F3', 9999.99);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (28, '0xD3F1B0C9A2E7D4F5C1B6A3F8D0E9C4B7A3F1C2E6', 1845.76);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (29, '0xE4C8B1F3A9D2E7F5B0C3A6D4E1B9C0F7D2A3F9B8', 25.00);
INSERT INTO Wallets (UserID, PublicKey, Balance) VALUES (30, '0xF5B0A3D9C4F1E6B7D3A2C8F0B9E7A4C1F3D0C9A2', 760.55);


INSERT INTO Categories (CategoryName) VALUES 
('Digital Art'),
('Pixel Art'),
('Calligraphy'),
('Islamic Art'),
('Pakistani Culture'),
('Sci-Fi'),
('Nature'),
('Abstract'),
('Photography'),
('3D Modeling');


INSERT INTO Collections (CollectionName, CreatorID, CategoryID) VALUES
('Neo Karachi Nights', 1, 1),
('Pixel Dynasty', 2, 2),
('Scripted Soul', 3, 3),
('Noor-e-Quran', 4, 4),
('Truck Art Revival', 5, 5),
('Future Mughals', 6, 6),
('Mystic Mountains', 7, 7),
('Echoed Patterns', 8, 8),
('Lahori Lights', 9, 1),
('MetaWaris', 10, 6),
('Calligraphic Realms', 11, 3),
('Digital Dastarkhwan', 12, 5),
('Hues of Faith', 13, 4),
('Dreamscapes', 14, 9),
('Nature Whisperers', 15, 7),
('Chitrali Wonders', 16, 5),
('Glitchy Reveries', 17, 8),
('Desi Cyberpunk', 18, 6),
('Vivid Perspectives', 19, 9),
('Sculpted Dimensions', 20, 10);

INSERT INTO NFTs (Title, Description, CollectionID, OwnerID, MintedAt) VALUES
('Karachi Glitchscape', 'A surreal digital rendering of Karachi�s skyline under a neon storm.', 1, 3, '2025-05-01 14:12:33'),
('Pixel Roti', 'Pixel art of a perfectly round roti in space.', 2, 5, '2025-05-03 11:30:45'),
('Qalam Vibes', 'Animated Urdu calligraphy with shifting colors.', 3, 7, '2025-05-04 09:22:10'),
('Verse of Light', 'Illuminated verse from Surah Noor, styled with gold calligraphy.', 4, 6, '2025-05-06 17:45:26'),
('Truck of Dreams', 'Classic truck art blended with glitch effects.', 5, 10, '2025-05-07 20:05:40'),
('Neo Emperor', 'Mughal emperor imagined as a cyberpunk king.', 6, 12, '2025-05-08 22:10:10'),
('Frozen Himalayas', 'Hyper-real 3D render of Pakistani mountains.', 7, 9, '2025-05-09 08:55:14'),
('Geometric Haveli', 'Vector-based art inspired by traditional havelis.', 8, 11, '2025-05-10 14:37:59'),
('Desi Neon Rickshaw', '3D neon rickshaw zooming through a digital multiverse.', 9, 8, '2025-05-11 10:20:47'),
('Cyber Mujahid', 'Stylized warrior in augmented reality armor.', 10, 13, '2025-05-12 12:12:12'),
('Midnight Script', 'Dark-themed Urdu calligraphy with slow fade animation.', 11, 15, '2025-05-13 07:45:33'),
('Biryani in Space', 'Low-poly biryani plate orbiting Mars.', 12, 14, '2025-05-14 17:21:18'),
('Light Within', 'Islamic art glowing with inner light on a black background.', 13, 16, '2025-05-15 13:11:11'),
('City in a Raindrop', 'Macro photo of a city reflected in a raindrop, digitally enhanced.', 14, 17, '2025-05-16 09:55:22'),
('Echo Leaves', 'Nature-based fractal art in autumn palette.', 15, 18, '2025-05-17 10:10:10'),
('Kalash Dreamer', 'Portrait of a Kalash girl with digital motifs.', 16, 19, '2025-05-18 08:35:47'),
('Pixel Mirage', 'Desert scene made entirely in pixel art.', 17, 20, '2025-05-19 15:27:36'),
('Peshawar Pulse', 'Dynamic glitch art of Peshawar streets.', 18, 21, '2025-05-20 17:42:00'),
('Lens of Truth', 'Photograph of a child�s eyes with hyperrealistic details.', 19, 22, '2025-05-21 19:29:15'),
('Digital Dervish', 'Animated whirl of a dervish blending tradition with tech.', 20, 23, '2025-05-22 14:44:33'),
('Cyber Soul Qawwali', 'Neon-lit Qawwali gathering in VR.', 1, 24, '2025-05-23 16:02:51'),
('AI Mughal Garden', 'AI-generated version of a Mughal garden.', 6, 25, '2025-05-24 11:19:27'),
('Fractal Mosque', 'Islamic mosque pattern looped in fractals.', 13, 26, '2025-05-25 13:34:11'),
('Time Traveler�s Truck', 'Pakistani truck flying through time.', 5, 27, '2025-05-26 09:49:05'),
('Digital Nomad', 'Concept art of a Pakistani woman in a sci-fi landscape.', 18, 28, '2025-05-27 12:05:06'),
('The Forgotten Shrine', 'Ruins of an old Sufi shrine rendered in 3D.', 7, 29, '2025-05-28 15:15:15'),
('Pixel Pakoras', 'Cute animated pakoras with eyes and smiles.', 2, 30, '2025-05-29 17:00:00'),
('Sufi Spark', 'Whirling dervish represented as glowing energy lines.', 20, 2, '2025-05-30 11:11:11'),
('Lahore Lights', 'A night aerial render of Lahore with LED effects.', 9, 4, '2025-06-01 08:30:30'),
('Wazir Khan Portal', 'Wazir Khan Mosque shown as a time-traveling portal.', 16, 1, '2025-06-02 20:00:00');

INSERT INTO Tags (TagName) VALUES
('digitalart'),
('glitch'),
('calligraphy'),
('pixel'),
('truckart'),
('islamic'),
('photography'),
('cyberpunk'),
('nature'),
('culture'),
('surreal'),
('portrait'),
('abstract'),
('3drender'),
('animation'),
('urdu'),
('biryani'),
('landscape'),
('architecture'),
('space'),
('pakistan'),
('sufism'),
('ai'),
('minimalism'),
('colors'),
('neon'),
('fantasy'),
('vector'),
('heritage'),
('mughal');


INSERT INTO NFT_Tags (NFTID, TagID) VALUES
(1, 1), (1, 3), (1, 7),
(2, 4), (2, 9), (2, 21),
(3, 2), (3, 5), (3, 12),
(4, 6), (4, 8), (4, 20),
(5, 11), (5, 13), (5, 27),
(6, 3), (6, 10), (6, 25),
(7, 14), (7, 15), (7, 28),
(8, 1), (8, 4), (8, 19),
(9, 2), (9, 5), (9, 17),
(10, 6), (10, 7), (10, 18),
(11, 9), (11, 20), (11, 29),
(12, 12), (12, 13), (12, 26),
(13, 14), (13, 22), (13, 30),
(14, 1), (14, 8), (14, 10),
(15, 16), (15, 18), (15, 24),
(16, 4), (16, 5), (16, 19),
(17, 3), (17, 6), (17, 21),
(18, 2), (18, 12), (18, 27),
(19, 9), (19, 11), (19, 25),
(20, 13), (20, 14), (20, 28),
(21, 7), (21, 15), (21, 22),
(22, 8), (22, 10), (22, 26),
(23, 16), (23, 20), (23, 29),
(24, 17), (24, 18), (24, 30),
(25, 1), (25, 19), (25, 23),
(26, 2), (26, 5), (26, 24),
(27, 6), (27, 9), (27, 27),
(28, 11), (28, 12), (28, 30),
(29, 7), (29, 8), (29, 25),
(30, 3), (30, 10), (30, 26);


INSERT INTO Listings (NFTID, SellerID, Price, ListedAt, IsActive) VALUES
(1, 5, 150.00, '2025-05-20 10:30:00', 1),
(2, 12, 320.50, '2025-05-22 12:45:00', 1),
(3, 7, 450.75, '2025-05-25 08:15:00', 1),
(4, 20, 75.00, '2025-05-26 14:00:00', 1),
(5, 3, 99.99, '2025-05-28 16:30:00', 1),
(6, 1, 500.00, '2025-05-30 11:00:00', 1),
(7, 15, 250.00, '2025-06-01 09:20:00', 1),
(8, 22, 120.00, '2025-06-02 17:40:00', 1),
(9, 10, 800.00, '2025-06-03 13:50:00', 1),
(10, 18, 60.00, '2025-06-04 07:10:00', 1),
(11, 25, 110.00, '2025-06-04 09:25:00', 1),
(12, 8, 340.00, '2025-06-04 15:35:00', 1),
(13, 6, 180.00, '2025-06-04 10:55:00', 1),
(14, 14, 275.50, '2025-06-04 08:45:00', 1),
(15, 21, 500.00, '2025-06-04 12:15:00', 1),
(16, 9, 90.00, '2025-06-04 14:05:00', 1),
(17, 2, 45.00, '2025-06-04 11:35:00', 1),
(18, 4, 230.00, '2025-06-04 13:50:00', 1),
(19, 11, 410.00, '2025-06-04 16:20:00', 1),
(20, 13, 360.00, '2025-06-04 15:10:00', 1),
(21, 17, 700.00, '2025-06-04 10:30:00', 1),
(22, 19, 150.00, '2025-06-04 14:45:00', 1),
(23, 24, 490.00, '2025-06-04 12:40:00', 1),
(24, 23, 200.00, '2025-06-04 09:55:00', 1),
(25, 16, 95.00, '2025-06-04 08:30:00', 1),
(26, 27, 130.00, '2025-06-04 11:10:00', 1),
(27, 26, 270.00, '2025-06-04 15:20:00', 1),
(28, 29, 480.00, '2025-06-04 13:40:00', 1),
(29, 28, 350.00, '2025-06-04 16:00:00', 1),
(30, 30, 190.00, '2025-06-04 09:15:00', 1);



INSERT INTO Bids (ListingID, BidderID, BidAmount, BidAt) VALUES
(1, 2, 155.00, '2025-05-20 11:00:00'),
(1, 9, 160.00, '2025-05-20 12:15:00'),
(1, 4, 165.00, '2025-05-20 13:45:00'),

(2, 5, 325.00, '2025-05-22 13:00:00'),
(2, 18, 330.50, '2025-05-22 14:10:00'),

(3, 10, 460.00, '2025-05-25 09:00:00'),
(3, 12, 470.00, '2025-05-25 10:20:00'),

(4, 7, 80.00, '2025-05-26 15:00:00'),
(4, 3, 85.00, '2025-05-26 16:30:00'),

(5, 11, 100.00, '2025-05-28 17:00:00'),
(5, 1, 105.00, '2025-05-28 18:20:00'),

(6, 14, 510.00, '2025-05-30 12:00:00'),

(7, 3, 260.00, '2025-06-01 10:00:00'),
(7, 8, 270.00, '2025-06-01 11:20:00'),

(8, 15, 125.00, '2025-06-02 18:00:00'),
(8, 21, 130.00, '2025-06-02 19:10:00'),

(9, 13, 810.00, '2025-06-03 14:00:00'),

(10, 1, 65.00, '2025-06-04 08:00:00'),

(11, 17, 115.00, '2025-06-04 10:00:00'),

(12, 2, 350.00, '2025-06-04 16:00:00'),

(13, 9, 185.00, '2025-06-04 11:30:00'),

(14, 22, 280.00, '2025-06-04 09:00:00'),

(15, 4, 510.00, '2025-06-04 12:30:00'),

(16, 5, 95.00, '2025-06-04 14:30:00'),

(17, 10, 50.00, '2025-06-04 12:00:00'),

(18, 11, 235.00, '2025-06-04 14:50:00'),

(19, 1, 420.00, '2025-06-04 16:30:00'),

(20, 7, 365.00, '2025-06-04 15:40:00'),

(21, 6, 710.00, '2025-06-04 11:00:00'),

(22, 3, 155.00, '2025-06-04 15:00:00'),

(23, 8, 500.00, '2025-06-04 13:00:00'),

(24, 19, 210.00, '2025-06-04 10:00:00'),

(25, 20, 100.00, '2025-06-04 09:00:00'),

(26, 1, 135.00, '2025-06-04 11:30:00'),

(27, 2, 280.00, '2025-06-04 15:30:00'),

(28, 4, 490.00, '2025-06-04 13:30:00'),

(29, 5, 355.00, '2025-06-04 16:10:00'),

(30, 6, 195.00, '2025-06-04 09:30:00'),

-- Additional bids for diversity:

(1, 3, 170.00, '2025-05-20 14:30:00'),
(2, 7, 335.00, '2025-05-22 15:00:00'),
(3, 1, 475.00, '2025-05-25 11:00:00'),
(4, 12, 90.00, '2025-05-26 17:00:00'),
(5, 14, 110.00, '2025-05-28 19:00:00'),
(6, 13, 520.00, '2025-05-30 13:00:00'),
(7, 11, 275.00, '2025-06-01 12:00:00'),
(8, 9, 135.00, '2025-06-02 20:00:00');


INSERT INTO Transactions (NFTID, BuyerID, SellerID, SalePrice, TransactionDate) VALUES
(1, 2, 1, 160.00, '2025-05-21 09:30:00'),
(2, 18, 5, 330.50, '2025-05-23 14:45:00'),
(3, 12, 6, 470.00, '2025-05-26 11:10:00'),
(4, 3, 7, 85.00, '2025-05-27 17:20:00'),
(5, 1, 11, 105.00, '2025-05-29 19:30:00'),
(6, 14, 8, 510.00, '2025-05-31 13:50:00'),
(7, 8, 9, 270.00, '2025-06-02 12:20:00'),
(8, 21, 10, 130.00, '2025-06-03 20:15:00'),
(9, 13, 11, 810.00, '2025-06-04 15:00:00'),
(10, 1, 12, 65.00, '2025-06-04 16:45:00'),
(11, 17, 13, 115.00, '2025-06-05 10:30:00'),
(12, 2, 14, 350.00, '2025-06-05 14:00:00'),
(13, 9, 15, 185.00, '2025-06-05 18:30:00'),
(14, 22, 16, 280.00, '2025-06-06 09:15:00'),
(15, 4, 17, 510.00, '2025-06-06 12:40:00'),
(16, 5, 18, 95.00, '2025-06-06 14:00:00'),
(17, 10, 19, 50.00, '2025-06-06 16:20:00'),
(18, 11, 20, 235.00, '2025-06-07 13:30:00'),
(19, 1, 21, 420.00, '2025-06-07 15:45:00'),
(20, 7, 22, 365.00, '2025-06-08 11:10:00'),
(21, 6, 23, 710.00, '2025-06-08 13:50:00'),
(22, 3, 24, 155.00, '2025-06-08 15:00:00'),
(23, 8, 25, 500.00, '2025-06-09 10:05:00'),
(24, 19, 26, 210.00, '2025-06-09 12:15:00'),
(25, 20, 27, 100.00, '2025-06-09 14:40:00'),
(26, 1, 28, 135.00, '2025-06-09 16:25:00'),
(27, 2, 29, 280.00, '2025-06-10 11:35:00'),
(28, 4, 30, 490.00, '2025-06-10 13:20:00'),
(29, 5, 1, 355.00, '2025-06-10 15:45:00'),
(30, 6, 2, 195.00, '2025-06-10 17:00:00');


INSERT INTO Royalties (NFTID, CreatorID, Percentage) VALUES
(1, 1, 5.00),
(2, 5, 7.50),
(3, 6, 10.00),
(4, 7, 6.00),
(5, 11, 8.00),
(6, 8, 5.50),
(7, 9, 12.00),
(8, 10, 3.00),
(9, 11, 7.00),
(10, 12, 6.50),
(11, 13, 5.00),
(12, 14, 4.00),
(13, 15, 8.50),
(14, 16, 10.00),
(15, 17, 5.00),
(16, 18, 6.50),
(17, 19, 7.00),
(18, 20, 9.00),
(19, 21, 8.00),
(20, 22, 7.00),
(21, 23, 5.00),
(22, 24, 6.00),
(23, 25, 10.00),
(24, 26, 4.50),
(25, 27, 6.00),
(26, 28, 5.50),
(27, 29, 7.00),
(28, 30, 8.00),
(29, 1, 6.00),
(30, 2, 9.50);

INSERT INTO Likes (UserID, NFTID, LikedAt) VALUES
(1, 5, '2025-05-01 10:15:00'),
(2, 7, '2025-05-02 14:22:00'),
(3, 9, '2025-05-03 09:10:00'),
(4, 1, '2025-05-04 16:35:00'),
(5, 3, '2025-05-05 11:50:00'),
(6, 4, '2025-05-06 12:05:00'),
(7, 6, '2025-05-07 18:40:00'),
(8, 8, '2025-05-08 14:15:00'),
(9, 10, '2025-05-09 19:55:00'),
(10, 2, '2025-05-10 13:30:00'),
(11, 11, '2025-05-11 15:45:00'),
(12, 12, '2025-05-12 10:25:00'),
(13, 13, '2025-05-13 09:15:00'),
(14, 14, '2025-05-14 20:05:00'),
(15, 15, '2025-05-15 17:30:00'),
(16, 16, '2025-05-16 08:40:00'),
(17, 17, '2025-05-17 12:55:00'),
(18, 18, '2025-05-18 14:35:00'),
(19, 19, '2025-05-19 16:20:00'),
(20, 20, '2025-05-20 11:45:00'),
(21, 21, '2025-05-21 10:10:00'),
(22, 22, '2025-05-22 15:35:00'),
(23, 23, '2025-05-23 13:40:00'),
(24, 24, '2025-05-24 09:05:00'),
(25, 25, '2025-05-25 18:30:00'),
(26, 26, '2025-05-26 14:50:00'),
(27, 27, '2025-05-27 16:15:00'),
(28, 28, '2025-05-28 12:45:00'),
(29, 29, '2025-05-29 11:30:00'),
(30, 30, '2025-05-30 10:00:00');

INSERT INTO Reports (ReporterID, NFTID, Reason, ReportedAt) VALUES
(1, 3, 'Inappropriate content', '2025-05-05 13:22:00'),
(2, 6, 'Copyright violation', '2025-05-06 09:45:00'),
(3, 2, 'Spam or scam', '2025-05-07 16:30:00'),
(4, 8, 'Misleading description', '2025-05-08 11:20:00'),
(5, 10, 'Offensive imagery', '2025-05-09 14:55:00'),
(6, 1, 'Duplicate NFT', '2025-05-10 12:05:00'),
(7, 4, 'Fake artwork', '2025-05-11 17:10:00'),
(8, 7, 'Violates terms of service', '2025-05-12 08:35:00'),
(9, 9, 'Inappropriate content', '2025-05-13 10:40:00'),
(10, 5, 'Copyright violation', '2025-05-14 15:25:00'),
(11, 12, 'Spam or scam', '2025-05-15 09:30:00'),
(12, 11, 'Misleading description', '2025-05-16 13:15:00'),
(13, 15, 'Offensive imagery', '2025-05-17 11:50:00'),
(14, 14, 'Duplicate NFT', '2025-05-18 18:05:00'),
(15, 13, 'Fake artwork', '2025-05-19 10:10:00'),
(16, 16, 'Violates terms of service', '2025-05-20 16:30:00'),
(17, 18, 'Inappropriate content', '2025-05-21 14:25:00'),
(18, 17, 'Copyright violation', '2025-05-22 08:45:00'),
(19, 20, 'Spam or scam', '2025-05-23 12:55:00'),
(20, 19, 'Misleading description', '2025-05-24 10:35:00'),
(21, 22, 'Offensive imagery', '2025-05-25 09:15:00'),
(22, 21, 'Duplicate NFT', '2025-05-26 15:20:00'),
(23, 24, 'Fake artwork', '2025-05-27 17:45:00'),
(24, 23, 'Violates terms of service', '2025-05-28 11:30:00'),
(25, 26, 'Inappropriate content', '2025-05-29 14:40:00'),
(26, 25, 'Copyright violation', '2025-05-30 13:10:00'),
(27, 28, 'Spam or scam', '2025-05-31 10:20:00'),
(28, 27, 'Misleading description', '2025-06-01 12:50:00'),
(29, 30, 'Offensive imagery', '2025-06-02 16:35:00'),
(30, 29, 'Duplicate NFT', '2025-06-03 09:00:00');

INSERT INTO Favorites (UserID, CollectionID, FavoritedAt) VALUES
(1, 2, '2025-05-01 10:00:00'),
(2, 3, '2025-05-02 11:15:00'),
(3, 1, '2025-05-03 09:45:00'),
(4, 5, '2025-05-04 14:20:00'),
(5, 4, '2025-05-05 16:10:00'),
(6, 6, '2025-05-06 13:55:00'),
(7, 7, '2025-05-07 10:30:00'),
(8, 8, '2025-05-08 12:40:00'),
(9, 9, '2025-05-09 15:05:00'),
(10, 10, '2025-05-10 11:50:00'),
(11, 11, '2025-05-11 13:30:00'),
(12, 12, '2025-05-12 14:45:00'),
(13, 13, '2025-05-13 10:20:00'),
(14, 14, '2025-05-14 16:35:00'),
(15, 15, '2025-05-15 09:10:00'),
(16, 1, '2025-05-16 12:55:00'),
(17, 2, '2025-05-17 14:15:00'),
(18, 3, '2025-05-18 11:05:00'),
(19, 4, '2025-05-19 16:25:00'),
(20, 5, '2025-05-20 10:40:00'),
(21, 6, '2025-05-21 15:30:00'),
(22, 7, '2025-05-22 12:20:00'),
(23, 8, '2025-05-23 13:55:00'),
(24, 9, '2025-05-24 09:50:00'),
(25, 10, '2025-05-25 16:00:00'),
(26, 11, '2025-05-26 10:30:00'),
(27, 12, '2025-05-27 14:45:00'),
(28, 13, '2025-05-28 11:15:00'),
(29, 14, '2025-05-29 15:20:00'),
(30, 15, '2025-05-30 09:05:00');


INSERT INTO NFT_Views (NFTID, ViewerID, ViewedAt) VALUES
(1, 2, '2025-05-01 09:15:00'),
(2, 3, '2025-05-01 10:20:00'),
(3, 1, '2025-05-02 14:30:00'),
(4, 5, '2025-05-03 11:45:00'),
(5, 6, '2025-05-03 16:10:00'),
(6, 4, '2025-05-04 13:05:00'),
(7, 8, '2025-05-05 12:50:00'),
(8, 7, '2025-05-05 15:25:00'),
(9, 9, '2025-05-06 10:40:00'),
(10, 10, '2025-05-06 14:35:00'),
(11, 12, '2025-05-07 09:20:00'),
(12, 11, '2025-05-07 17:30:00'),
(13, 15, '2025-05-08 08:50:00'),
(14, 14, '2025-05-08 12:15:00'),
(15, 13, '2025-05-09 14:00:00'),
(16, 16, '2025-05-09 16:45:00'),
(17, 18, '2025-05-10 11:35:00'),
(18, 17, '2025-05-10 13:40:00'),
(19, 20, '2025-05-11 10:10:00'),
(20, 19, '2025-05-11 15:55:00'),
(21, 22, '2025-05-12 09:25:00'),
(22, 21, '2025-05-12 12:30:00'),
(23, 24, '2025-05-13 14:20:00'),
(24, 23, '2025-05-13 16:50:00'),
(25, 26, '2025-05-14 11:15:00'),
(26, 25, '2025-05-14 13:45:00'),
(27, 28, '2025-05-15 08:40:00'),
(28, 27, '2025-05-15 12:55:00'),
(29, 30, '2025-05-16 14:10:00'),
(30, 29, '2025-05-16 17:25:00');

-- ALTER TABLE Users ADD ProfileImage VARCHAR(255);
ALTER TABLE NFTs ADD ImagePath VARCHAR(255);

