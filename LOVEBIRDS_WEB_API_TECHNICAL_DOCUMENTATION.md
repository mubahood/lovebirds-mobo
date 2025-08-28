# Lovebirds Dating App - Web API System Technical Documentation

## 1. System Overview

The Lovebirds Web API is a comprehensive Laravel-based backend system that powers a modern dating application. Built with PHP/Laravel framework, it provides robust APIs, real-time chat functionality, advanced matching algorithms, and secure user management for a complete dating platform experience.

### 1.1 Technology Stack
- **Framework**: Laravel 10.x
- **Database**: MySQL 8.0+
- **Authentication**: JWT (JSON Web Tokens)
- **Real-time**: WebSocket/Pusher integration
- **Storage**: File system + Cloud storage support
- **Cache**: Redis (optional)
- **Queue**: Laravel Queues for background processing

## 2. Core Architecture

### 2.1 Model-View-Controller (MVC) Structure

#### **Models**
- **User.php**: Core user management with comprehensive dating profile fields
- **UserMatch.php**: Handles match creation, compatibility scoring, and match lifecycle
- **UserLike.php**: Manages likes, super likes, passes, and mutual like detection
- **ChatHead.php**: Chat conversation management for matched users
- **ChatMessage.php**: Individual message handling with multimedia support
- **ProfileBoost.php**: Premium features and profile visibility enhancement
- **ContentModerationLog.php**: Safety and content moderation system

#### **Controllers**
- **ApiController.php**: Main API controller handling all dating endpoints
- **ModerationAdminController.php**: Admin moderation interface
- **DynamicCrudController.php**: Generic CRUD operations

#### **Services**
- **DatingDiscoveryService.php**: Advanced user discovery and matching algorithms
- **ContentModerationService.php**: Automated content screening and safety

### 2.2 Database Schema

#### **Users Table (admin_users)**
```sql
-- Core user information
id, username, email, password, first_name, last_name, name, avatar

-- Dating profile fields
bio, tagline, dob, sex, sexual_orientation, height_cm, body_type
country, state, city, latitude, longitude, interests, lifestyle

-- Relationship preferences
looking_for, interested_in, age_range_min, age_range_max, max_distance_km
relationship_type, wants_kids, has_kids, smoking_habit, drinking_habit

-- Verification & safety
email_verified, phone_verified, photo_verified, account_status
verification_documents, last_online_at, online_status

-- Premium features
subscription_tier, subscription_expires, boost_active, super_likes_remaining
completed_profile_pct, matches_count, profile_views, likes_received
```

#### **UserMatches Table**
```sql
-- Match relationship
user_id, matched_user_id, status, match_type, matched_at

-- Conversation tracking
is_conversation_started, last_message_at, messages_count, conversation_starter

-- Compatibility & analytics
compatibility_score, match_reason, unmatched_at, unmatched_by, unmatch_reason
```

#### **UserLikes Table**
```sql
-- Like relationship
liker_id, liked_user_id, type (like/super_like/pass), status, is_mutual

-- Additional data
message, created_at, expires_at, metadata
```

#### **ChatHeads Table**
```sql
-- Chat session management
customer_id, product_owner_id, type, status, created_at, updated_at

-- Chat metadata
typing_status, blocked_users, last_message_preview, is_group_chat
```

#### **ChatMessages Table**
```sql
-- Message content
sender_id, receiver_id, message, message_type, status, created_at

-- Multimedia support
attachment_url, attachment_type, attachment_size, thumbnail_url

-- Message features
reply_to_message_id, reactions, read_at, delivered_at, metadata
```

## 3. API Architecture

### 3.1 Authentication System

#### **JWT-Based Authentication**
```php
// Login endpoint
POST /auth/login
{
    "email": "user@example.com",
    "password": "password"
}

// Response
{
    "code": 1,
    "message": "Login successful",
    "data": {
        "user": { /* user object */ },
        "token": "jwt_token_here"
    }
}
```

#### **Registration Flow**
```php
POST /auth/register
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "secure_password",
    "phone_number": "+1234567890",
    "dob": "1990-01-01",
    "sex": "Male"
}
```

### 3.2 Dating Core APIs

#### **User Discovery & Matching**

**GET /discover-users** - Advanced User Discovery
```php
// Supported filters
max_distance, age_min, age_max, city, country, state
education_level, religion, smoking_habit, drinking_habit
pet_preference, looking_for, verified_only, recently_active
online_only, shared_interests, mutual_interest_only

// Response with compatibility scoring
{
    "code": 1,
    "data": {
        "users": [
            {
                "id": 123,
                "name": "Jane Smith",
                "age": 28,
                "distance": 5.2,
                "compatibility_score": 87,
                "compatibility_reasons": ["Shared interests", "Age compatible"]
            }
        ]
    }
}
```

**GET /swipe-discovery** - Tinder-style Discovery
```php
// Returns one user at a time for swiping
{
    "code": 1,
    "data": {
        "user": { /* single user for swiping */ },
        "remaining_swipes": 10
    }
}
```

#### **Swipe Actions**

**POST /swipe-action** - Handle Like/Pass
```php
{
    "user_id": 123,
    "action": "like", // like, super_like, pass
    "message": "Hey there!" // Optional for super likes
}

// Response includes match detection
{
    "code": 1,
    "data": {
        "action_result": "like_sent",
        "is_match": true,
        "match_id": 456
    }
}
```

#### **Match Management**

**GET /my-matches** - User's Matches
```php
{
    "code": 1,
    "data": {
        "matches": [
            {
                "match_id": 456,
                "user": { /* matched user details */ },
                "matched_at": "2024-01-15T10:30:00Z",
                "last_message_at": "2024-01-16T14:22:00Z",
                "compatibility_score": 87,
                "messages_count": 12
            }
        ]
    }
}
```

**GET /who-liked-me** - Users Who Liked Current User
```php
{
    "code": 1,
    "data": {
        "likes": [
            {
                "user": { /* user who liked */ },
                "like_type": "super_like",
                "message": "Love your profile!",
                "created_at": "2024-01-15T09:15:00Z"
            }
        ]
    }
}
```

### 3.3 Enhanced Chat System

#### **Dating Chat Creation**
```php
POST /create-dating-chat
{
    "match_id": 456
}

// Validates match relationship before creating chat
{
    "code": 1,
    "data": {
        "chat_id": 789,
        "chat_head": { /* chat details */ }
    }
}
```

#### **Multimedia Messaging**
```php
POST /send-message
{
    "chat_id": 789,
    "message": "Hello!",
    "message_type": "text", // text, photo, video, voice, document, location
    "attachment_url": "https://...", // For multimedia
    "reply_to_message_id": 123 // For replies
}
```

#### **Real-time Features**
```php
POST /set-typing-status
{
    "chat_id": 789,
    "is_typing": true
}

POST /react-to-message
{
    "message_id": 456,
    "reaction": "❤️"
}
```

### 3.4 Premium Features

#### **Profile Boost**
```php
POST /boost-profile
{
    "boost_duration": 30 // minutes
}

// Increases profile visibility in discovery
{
    "code": 1,
    "data": {
        "boost_active": true,
        "boost_expires_at": "2024-01-15T11:00:00Z",
        "estimated_additional_views": 50
    }
}
```

#### **Super Likes**
```php
POST /super-like
{
    "user_id": 123,
    "message": "You seem amazing!"
}

// Premium feature with higher match probability
{
    "code": 1,
    "data": {
        "super_likes_remaining": 4,
        "notification_sent": true
    }
}
```

## 4. Advanced Features

### 4.1 Compatibility Scoring Algorithm

The system implements a sophisticated 100-point compatibility scoring system:

```php
// Compatibility factors and weights
- Age Compatibility (20 points): Matches user age preferences
- Location Proximity (25 points): Distance-based scoring using Haversine formula
- Shared Interests (20 points): Common interests matching
- Lifestyle Compatibility (15 points): Religion, education, habits alignment
- Profile Completeness (10 points): Quality profile scoring
- Activity Level (10 points): Recent activity weighting
```

#### **Smart Recommendations Engine**
```php
// Multi-factor algorithm combining:
- Distance proximity calculations
- Activity recency prioritization
- Profile completeness scoring
- Mutual compatibility assessment
- Shared interests analysis
- Behavioral pattern matching
```

### 4.2 GPS-Based Discovery

#### **Distance Calculations**
```php
// Haversine formula implementation for accurate distance
public function getDistanceFrom($otherUser) {
    $earthRadius = 6371; // kilometers
    
    $lat1 = deg2rad($this->latitude);
    $lon1 = deg2rad($this->longitude);
    $lat2 = deg2rad($otherUser->latitude);
    $lon2 = deg2rad($otherUser->longitude);
    
    $dLat = $lat2 - $lat1;
    $dLon = $lon2 - $lon1;
    
    $a = sin($dLat/2) * sin($dLat/2) + 
         cos($lat1) * cos($lat2) * sin($dLon/2) * sin($dLon/2);
    $c = 2 * atan2(sqrt($a), sqrt(1-$a));
    
    return round($earthRadius * $c, 2);
}
```

### 4.3 Content Moderation & Safety

#### **Automated Content Screening**
```php
- Photo verification and inappropriate content detection
- Text message filtering for harassment prevention
- Spam and bot detection algorithms
- Automated flagging of suspicious behavior patterns
```

#### **User Safety Features**
```php
- Block/unblock functionality
- Report users and content
- Privacy controls and data protection
- Age verification and consent management
```

## 5. Real-time Features

### 5.1 WebSocket Integration
```php
// Real-time notifications for:
- New matches (with celebration effects)
- Incoming messages
- Like notifications
- Typing indicators
- Online status updates
- Profile boost notifications
```

### 5.2 Push Notifications
```php
// Notification types
- Match notifications: "It's a Match! 💕"
- Message notifications: "New message from [Name]"
- Like notifications: "[Name] liked your profile"
- Super like notifications: "[Name] super liked you!"
- App engagement: "You have new potential matches"
```

## 6. Security & Privacy

### 6.1 Data Protection
```php
- JWT token-based authentication
- Password hashing with PHP password_hash()
- Sensitive data filtering in API responses
- HTTPS enforcement
- SQL injection prevention through Eloquent ORM
- XSS protection through input validation
```

### 6.2 User Privacy Controls
```php
- Blocked user exclusion from discovery
- Profile visibility settings
- Location privacy options
- Photo verification requirements
- Account deletion and data cleanup
```

## 7. Performance & Scalability

### 7.1 Database Optimization
```php
- Indexed columns for fast queries (user_id, location coordinates)
- Pagination for large result sets
- Efficient query structures with relationships
- Cache layer for frequently accessed data
```

### 7.2 API Performance
```php
- Rate limiting to prevent abuse
- Pagination with configurable page sizes
- Efficient filtering with database-level constraints
- Optimized image handling and thumbnails
```

## 8. Admin & Moderation Tools

### 8.1 Admin Dashboard
```php
- User management and verification
- Content moderation interface
- Match success analytics
- Abuse report handling
- System health monitoring
```

### 8.2 Analytics & Insights
```php
- User engagement metrics
- Match success rates
- Popular features tracking
- Geographic user distribution
- Revenue and subscription analytics
```

## 9. API Testing & Documentation

### 9.1 Test Coverage
```php
// Comprehensive test files:
- test_dating_endpoints.php: Core dating functionality
- test_enhanced_chat_comprehensive.php: Chat system testing
- test_api_4_premium_features.php: Premium feature validation
- test_discovery_system.php: Discovery algorithm testing
```

### 9.2 Development Tools
```php
// Helper scripts for development:
- create_dating_test_data.php: Generate test users and relationships
- debug_auth.php: Authentication debugging
- show_test_data_summary.php: Data validation tools
```

## 10. Deployment & Infrastructure

### 10.1 Environment Configuration
```php
- Production/staging/development environments
- Environment-specific database configurations
- SSL certificate management
- CDN integration for media files
```

### 10.2 Monitoring & Maintenance
```php
- Error logging and tracking
- Performance monitoring
- Database backup strategies
- Security update procedures
- User data backup and recovery
```

---

## Conclusion

The Lovebirds Web API provides a comprehensive, production-ready backend for a modern dating application. With advanced matching algorithms, real-time chat capabilities, robust security measures, and scalable architecture, it supports all essential dating app features while maintaining high performance and user safety standards.

The system is designed for:
- **High Performance**: Optimized queries and efficient algorithms
- **Scalability**: Modular architecture supporting growth
- **Security**: Comprehensive privacy and safety measures
- **User Experience**: Real-time features and smart matching
- **Admin Control**: Complete moderation and analytics tools

This technical foundation enables the development of a competitive dating platform that prioritizes user experience, safety, and meaningful connections.
