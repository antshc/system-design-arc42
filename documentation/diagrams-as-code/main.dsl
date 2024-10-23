workspace "highly-scalable-image-sharing-platform" "This is an example workspace to illustrate system design as code approach" {

    model {
        user = person "User" "A registered user of the image sharing platform." "User,business"
        userTech = person "Users" "A registered users" "User,tech"
        follower = person "Follower" "A registered user of the image sharing platform." "User,business"
        contentManager = person "ContentManager" "A employee of the harmful content detection department." "Staff,business"

        group "Image sharing platform" {
            storage = softwaresystem "Azure storage" "Uses to store users images." "Existing System"
            googleauth = softwaresystem "Google auth system" "Uses to authenticate users with google account." "Existing System"
            cdn = softwaresystem "Azure CDN" "Cache images." "Existing System"
            
            imageSharingPlatform = softwaresystem "Image sharing system" "Social network system, where user can share images, follow other people." {
                 webApp = container "Web GUI" "Provides all of the image sharing platform functionality to users via their web browser." "Angular" "Web Browser"
                 postsApiApp = container "Posts API" "Provides posts managament functionality via a JSON/HTTP API." "ASP .NET API, C#"
                 imagesProcessingFuncApp = container "Images Processing Func" "Resize images, removes temporary." "Functions, C#"
                 postsDatabase = container "Posts Database" "Manage user posts, stores images urls." "NoSQL Document Schema" "Database"
                 timelinesApiApp = container "Timelines API" "Provides timelines functionality via a JSON/HTTP API." "ASP .NET API, C#"
                 timelinesDatabase = container "Timelines Database" "Stores user timelines." "NoSQL Key/Value Schema" "Database"
                 searchApiApp = container "Search API" "Users search a JSON/HTTP API." "ASP .NET API, C#"
                 searchDatabase = container "Search Database" "Stores users information, indexed for full text search" "NoSQL Document Schema, Lucena" "Database"
                 usersApiApp = container "Users API" "Users information managment, registration, login using JSON/HTTP API." "ASP .NET API, C#"
                 usersDatabase = container "Users Database" "Stores users account" "NoSQL Document Schema" "Database"
                 identityServerApp = container "Identity Server" "Authentication, Authorization JSON/HTTPS API." "ASP .NET API, C#"
                 gatewayApiApp = container "Gateway API" "Entry point to the system, hides internal APIs, authentication JSON/HTTPS API." "ASP .NET API, C#, Ocelot"
            }
        }

        # business relationships between people and software systems
        user -> imageSharingPlatform "Publish image, search users, follow other users, read posts from the timeline" "" "business"
        user -> googleauth "Redirects, enter credentials""" "business"
        follower -> imageSharingPlatform "Publish image, search users, follow other users, read posts from the timeline""""business"
        contentManager -> imageSharingPlatform "Verify content that doesn't passed harmful content verification""""business"
        imageSharingPlatform -> storage "Uploads, removes images" "" "business"
        imageSharingPlatform -> googleauth "Authenticate, verify token""" "business"
        
        # tech relationships
        userTech -> imageSharingPlatform "User information, images" "REST/HTTPs/JSON" "tech"
        userTech -> googleauth "Credentials" "" "tech"
        googleauth -> imageSharingPlatform  "JWT Token, username, email" "OAuth 2.0/HTTPS/JSON" "tech"
        imageSharingPlatform -> storage "Images" "REST/HTTPS/Binary" "tech"
        storage -> imageSharingPlatform "Blob file metadata" "REST/HTTPS/JSON" "tech"

        # relationships to/from containers
        user -> webApp "Visits fancy-pics.com/web using." "HTTPS"
        user -> cdn "Download images"  "HTTPS"
        webApp -> gatewayApiApp "fancy-pics.com/api" "HTTPS"
        
        gatewayApiApp -> postsApiApp "/posts" "JSON/HTTP"
        postsApiApp -> postsDatabase "Saves posts data."
        postsApiApp -> storage "Saves posts images."
        cdn -> storage "Pull images"
        imagesProcessingFuncApp -> storage "Saves resized images."
        imagesProcessingFuncApp -> storage "Listen for new images."
        
        gatewayApiApp -> timelinesApiApp "/timelines" "JSON/HTTP"
        timelinesApiApp -> timelinesDatabase "Stores posts as a timeline."

        gatewayApiApp -> searchApiApp "/search" "JSON/HTTP"
        searchApiApp -> searchDatabase "Full text search" "JSON/HTTP"

        gatewayApiApp -> usersApiApp "users" "JSON/HTTP"
        usersApiApp -> usersDatabase "Saves user info." "JSON/HTTP"
        usersApiApp -> identityServerApp "reads user email, user id"
        identityServerApp -> googleauth "Authentication"
        gatewayApiApp -> identityServerApp "Authentication"
    }

    views {
        systemlandscape "SystemLandscape" {
            include *
            autoLayout lr
        }

        systemcontext imageSharingPlatform "BusinessContext" {
            include *
            exclude element.tag==tech relationship.tag==tech
            animation {
                imageSharingPlatform
                user
                storage
                googleauth
            }
            autoLayout
        }

        systemcontext imageSharingPlatform "TechnicalContext" {
            include *
            exclude element.tag==business relationship.tag==business
            animation {
                imageSharingPlatform
                userTech
                storage
                googleauth
            }
            autoLayout
        }

        container imageSharingPlatform "Containers" {
            include *
            animation {
                webApp
                gatewayApiApp
                identityServerApp
                postsApiApp
                imagesProcessingFuncApp
                storage
                postsDatabase
                timelinesApiApp
                timelinesDatabase
                searchApiApp
                searchDatabase
                usersApiApp
                usersDatabase
                googleauth
            }
            autoLayout
        }

        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "User" {
                background #08427b
            }
            element "Staff" {
                background #999999
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Failover" {
                opacity 25
            }
        }
    }
}