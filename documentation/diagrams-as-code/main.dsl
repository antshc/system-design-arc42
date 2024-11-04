workspace "highly-scalable-image-sharing-platform" "This is an example workspace to illustrate system design as code approach" {

    model {
        properties {
            "structurizr.groupSeparator" "/"
        }

        user = person "User" "A registered user of the image sharing platform." "User,business"
        userTech = person "Users" "A registered users" "User,tech"
        follower = person "Follower" "A registered user what follows other users." "User,business"
        influencer = person "Influencer" "A registered user what has > 10k followers." "User,business"
        contentManager = person "ContentManager" "A employee of the harmful content detection department." "Staff,business"

        group "Image sharing platform" {
            storage = softwaresystem "Azure storage" "Uses to store users images." "Existing System"
            googleauth = softwaresystem "Google auth system" "Uses to authenticate users with google account." "Existing System"
            frontdoor = softwaresystem "Azure Front Door" "Cache images." "Existing System"
            
            imageSharingPlatform = softwaresystem "Image sharing system" "Social network system, where user can share images, follow other people." {
                webApp = container "Web GUI" "Provides all of the image sharing platform functionality to users via their web browser." "Angular" "Web Browser"
                postsApiApp = container "Posts API" "Provides posts managament functionality via a JSON/HTTP API." "ASP .NET API, C#" "components,timelines"
                imagesProcessingFuncApp = container "Images Processing Func" "Resize images, removes temporary." "Functions, C#"
                postsDatabase = container "Posts Database" "Manage user posts, stores images urls." "NoSQL Document Schema" "Database"
                timelinesApiApp = container "Timelines API" "Provides timelines functionality via a JSON/HTTP API." "ASP .NET API, C#" {
                    timelinesRepository = component "Timelines repository" "Manages CRUD operations for user timelines, ensuring efficient storage and retrieval in chronological order."
                    updatingTimelineConsumer = component "Updating timeline postCreated event consumer" "Triggers updating followers timelines" "MassTransit Consumer" "components,timelines"
                    followersTimelineUpdater = component "Followers timeline updater" "Updates followers' timelines with the latest posts from the users they follow" "c# classes" "components,timelines"
                    usersClient = component "Users client" "Get users data from users microservice" "HTTP client" "components,timelines"

                    influencersPostsRepository = component "Influencers posts repository" "Manages CRUD operations for influencer posts" "" "components,timelines"

                    getTimelineEndpoint = component "Timelines endpoint" "Handles query requests""Minimal API endpoint" "components,timelines"
                    timelineQuery = component "Timelines query" "Build user timeline query"
                }
                timelinesDatabase = container "Timelines Database" "Followers timelines, influencers posts." "NoSQL Key/Value Schema" "Database" {
                    timelinesTable = component "Timelines"
                    influencersPostsTable = component "Influencers posts"
                }
                searchApiApp = container "Search API" "Users search a JSON/HTTP API." "ASP .NET API, C#"
                searchDatabase = container "Search Database" "Stores users information, indexed for full text search" "NoSQL Document Schema, Lucena" "Database"
                usersApiApp = container "Users API" "Users information managment, registration, login using JSON/HTTP API." "ASP .NET API, C#"
                usersDatabase = container "Users Database" "Stores users account" "NoSQL Document Schema" "Database"
                identityServerApp = container "Identity Server" "Authentication, Authorization JSON/HTTPS API." "ASP .NET API, C#"
                identityServerDatabase = container "Identity Server Database" "Authentication, Authorization JSON/HTTPS API." "SQL Server" "Database"
            }
        }

        # business relationships between people and software systems
        user -> imageSharingPlatform "Publish image, search users, follow other users, read posts from the timeline" "" "business"
        user -> googleauth "Redirects, enter credentials""" "business"
        follower -> imageSharingPlatform "Publish image, search users, follow other users, read posts from the timeline""""business"
        influencer -> imageSharingPlatform "Publish image, search users, follow other users, read posts from the timeline" "" "business"
        contentManager -> imageSharingPlatform "Verify content that doesn't passed harmful content verification""""business"
        imageSharingPlatform -> storage "Uploads, removes images" "" "business"
        imageSharingPlatform -> googleauth "Authenticate, verify token""" "business"
        
        # tech relationships
        userTech -> imageSharingPlatform "User information, images" "REST/HTTPs/JSON" "tech"
        userTech -> googleauth "Credentials" "" "tech"
        googleauth -> imageSharingPlatform "JWT Token, username, email" "OAuth 2.0/HTTPS/JSON" "tech"
        imageSharingPlatform -> storage "Images" "REST/HTTPS/Binary" "tech"
        storage -> imageSharingPlatform "Blob file metadata" "REST/HTTPS/JSON" "tech"

        # relationships to/from containers
        user -> webApp "Visits fancy-pics.com/web using." "HTTPS"
        user -> frontdoor "Download images" "HTTPS"
        
        
        webApp -> postsApiApp "/posts" "JSON/HTTP" "posts"
        postsApiApp -> postsDatabase "Saves posts data."
        postsApiApp -> storage "Saves posts images."
        frontdoor -> storage "Pull images"
        imagesProcessingFuncApp -> storage "Saves resized images."
        imagesProcessingFuncApp -> storage "Listen for new images."
        
        webApp -> timelinesApiApp "/timelines" "JSON/HTTP"
        timelinesApiApp -> timelinesDatabase "Stores posts as a timeline."

        webApp -> searchApiApp "/search" "JSON/HTTP"
        searchApiApp -> searchDatabase "Full text search" "JSON/HTTP"

        webApp -> usersApiApp "/users" "JSON/HTTP"
        usersApiApp -> usersDatabase "Saves user info." "JSON/HTTP"
        usersApiApp -> identityServerApp "reads user email, user id"
        identityServerApp -> googleauth "Authentication"
        identityServerApp -> identityServerDatabase "Uses"
        webApp -> identityServerApp "Authentication" "JSON/HTTP"
    
        # components relations
        # timelines API
        # updating timeline
        postsApiApp -> updatingTimelineConsumer "uses" "messages:posts" "components,timelines"
        updatingTimelineConsumer -> followersTimelineUpdater "uses""" "components,timelines"
        followersTimelineUpdater -> usersClient "uses" """components,timelines"
        usersClient -> usersApiApp "uses" "REST/HTTP" "components,timelines"
        followersTimelineUpdater -> timelinesRepository "uses" "" "components,timelines"
        followersTimelineUpdater -> influencersPostsRepository "uses" "" "components,timelines"
        timelinesRepository -> timelinesDatabase "uses" "" "components,timelines"
        influencersPostsRepository -> timelinesDatabase "uses" "" "components,timelines"

        # query timelines
        webApp -> getTimelineEndpoint "uses" "REST/HTTP" "components,timelines"
        getTimelineEndpoint -> timelineQuery "uses" "" "components,timelines"
        timelineQuery -> usersClient "uses" "" "components,timelines"
        timelineQuery -> influencersPostsRepository "uses" "" "components,timelines"
        timelineQuery -> timelinesRepository "uses" "" "components,timelines"
    
        development = deploymentEnvironment "Development" {
            deploymentNode "development" "" "Subscription" "" {
                
                deploymentNode "rg-development-aks" "" "Resource group" "" {

                    privateLinkService = infrastructureNode "aks-ingress-pls" {
                        technology "Private link service"
                    }
                    deploymentNode "snet-development-aks" " ""vnet" "" {
                        lb = infrastructureNode "app-ingress-lb" {
                                    technology "Load balancer"
                                    description "Load balancer, external ip: 10.10.0.30"
                                    privateLinkService -> this "uses"
                                }
                        deploymentNode "aks-development-aks" "" "Azure kubernetes service" "" {
                            
                            deploymentNode "microservices" "" "namespace" "" {
                                ingress = infrastructureNode "app-ingress" {
                                    technology "Ingress"
                                    description "Routes traffic by rules: /web, /api/users, /api/posts, /api/timeline, /api/search"
                                    lb -> this "Redirect trafic to internal aks ingress service" "TCP/IP" ""
                                }
                                
                                deploymentNode "web" "" "Pod" "" 1 {
                                    containerInstance webapp {
                                        ingress -> this "/web"
                                    }
                                }
                                deploymentNode "users-api" "" "Replica Set" "" 3 {
                                    containerInstance usersApiApp {
                                        ingress -> this "/users"
                                    }
                                }
                                deploymentNode "posts-api" "" "Replica Set" "" 3 {
                                    containerInstance postsApiApp {
                                        ingress -> this "/posts"
                                    }
                                }
                                deploymentNode "timelines-api" "" "Replica Set" "" 3 {
                                    containerInstance timelinesApiApp {
                                        ingress -> this "/timeline"
                                    }
                                }
                                deploymentNode "search-api" "" "Replica Set" "" 3 {
                                    containerInstance searchApiApp {
                                        ingress -> this "/search"
                                    }
                                }
                                deploymentNode "identity-server" "" "Replica Set" "" 3 {
                                    containerInstance identityServerApp {
                                        ingress -> this "/auth"
                                    }
                                }
                            }
                        }
                    }
                }

                deploymentNode "Azure Cosmos DB" "Uses by developers to test features and bugs" "Azure Cosmos DB" "" {
                    deploymentNode "Development" "" "Cosmos DB Account" "" {
                        containerInstance postsDatabase
                        containerInstance usersDatabase
                        containerInstance timelinesDatabase
                    }
                }

                deploymentNode "Azure storage" "Uses by developers" "Azure storage" "" {
                    deploymentNode "storage-development" "Uses by developers" "Azure storage account" "" {
                        softwareSystemInstance storage 
                    }
                }
            }
            
        }

        production = deploymentEnvironment "Production" {
            deploymentNode "production" "" "Subscription" "" {
                deploymentNode "rg-production-frontdoor" "" "Resource group" "" {
                    frontDoorPrd = infrastructureNode "frontdoor-production" {
                        technology "Azure Front Door"
                    }
                    frontDoorAksPrivateEndpoint = infrastructureNode "frontdoor-aks-pe-production" {
                        technology "Azure private endpoint"
                        description "private endpoint managed by azure front door"
                        frontDoorPrd -> this "Uses"
                    }
                    frontDoorStoragePrivateEndpoint = infrastructureNode "frontdoor-storage-pe-production" {
                        technology "Azure private endpoint"
                        description "private endpoint managed by azure front door"
                        frontDoorPrd -> this "Uses"
                    }
                }
                deploymentNode "rg-production-aks" "" "Resource group" "" {

                    privateLinkServicePrd = infrastructureNode "aks-ingress-pls" {
                        technology "Private link service"
                        frontDoorAksPrivateEndpoint -> this "Uses"
                    }
                    deploymentNode "snet-production-aks" " ""vnet" "" {
                        lbPrd = infrastructureNode "app-ingress-lb" {
                                    technology "Load balancer"
                                    description "Load balancer, external ip: 10.10.0.30"
                                    privateLinkServicePrd -> this
                                }
                        deploymentNode "aks-production-aks" "" "Azure kubernetes service" "" {
                            
                            deploymentNode "microservices" "" "namespace" "" {
                                ingressPrd = infrastructureNode "app-ingress" {
                                    technology "Ingress"
                                    description "Routes traffic by rules: /web, /api/users, /api/posts, /api/timeline, /api/search"
                                    lbPrd -> this "Redirect trafic to internal aks ingress service" "TCP/IP" ""
                                }
                                
                                deploymentNode "web" "" "Pod" "" 1 {
                                    containerInstance webapp {
                                        ingressPrd -> this "/web"
                                    }
                                }
                                deploymentNode "users-api" "" "Replica Set" "" 3 {
                                    containerInstance usersApiApp {
                                        ingressPrd -> this "/users"
                                    }
                                }
                                deploymentNode "posts-api" "" "Replica Set" "" 3 {
                                    containerInstance postsApiApp {
                                        ingressPrd -> this "/posts"
                                    }
                                }
                                deploymentNode "timelines-api" "" "Replica Set" "" 3 {
                                    containerInstance timelinesApiApp {
                                        ingressPrd -> this "/timeline"
                                    }
                                }
                                deploymentNode "search-api" "" "Replica Set" "" 3 {
                                    containerInstance searchApiApp {
                                        ingressPrd -> this "/search"
                                    }
                                }
                                deploymentNode "identity-server" "" "Replica Set" "" 3 {
                                    containerInstance identityServerApp {
                                        ingressPrd -> this "/auth"
                                    }
                                }
                            }
                        }
                    }
                }

                deploymentNode "Azure Cosmos DB" "Uses by real users" "Azure Cosmos DB" "" {
                    deploymentNode "Production" "" "Cosmos DB Account" "" {
                        containerInstance postsDatabase
                        containerInstance usersDatabase
                        containerInstance timelinesDatabase
                    }
                }

                deploymentNode "Azure storage" "Uses by real users" "Azure storage" "" {
                    deploymentNode "storage-production" "Uses by real users" "Azure storage account" "" {
                        softwareSystemInstance storage {
                            frontDoorStoragePrivateEndpoint -> this "Cache content"
                        }
                    }
                }
            }
            
        }
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
            exclude relationship.tag==components
            animation {
                webApp
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
            autoLayout lr
        }

        dynamic imageSharingPlatform "TimelinesAPIContainer"{
            title "Timelines API"
            timelinesApiApp -> timelinesDatabase
            autoLayout
        }
        
        dynamic imageSharingPlatform "AuthenticationOAuthRuntime"{
            title "Authenticate user flow"
            user -> webApp "Initiates authentication"
            webApp -> identityServerApp "Requests authentication"
            identityServerApp -> googleauth "Delegates authentication via OAuth 2.0"
            identityServerApp -> identityServerDatabase "Verifies user identity and retrieves user details"
            identityServerApp -> webApp "Issues JWT access token upon successful authentication"
            autoLayout lr
        }

        component timelinesApiApp "TimelinesApiAppComponents" {
            include *
            autoLayout
        }

        dynamic timelinesApiApp "TimelinesApiAddInfluencerPosts" {
            title "Influencer followers timeline updating"
            postsApiApp -> updatingTimelineConsumer "dispatch post created event"
            updatingTimelineConsumer -> followersTimelineUpdater "Update timeline {userId,postId,imageUrl}"
            followersTimelineUpdater -> usersClient "Get user by Id"
            usersClient -> usersApiApp "GET users/{id}"
            usersApiApp -> usersClient "Returns user {'type' : 'influencer'}"
            usersClient -> followersTimelineUpdater "Returns user {'type' : 'influencer'}"
            followersTimelineUpdater -> influencersPostsRepository "if user type 'influencer', adds influencer post"
            influencersPostsRepository -> timelinesDatabase "influencers posts table"
            timelinesDatabase -> influencersPostsRepository "Returns"
            influencersPostsRepository -> followersTimelineUpdater "Returns"
            followersTimelineUpdater -> timelinesRepository "Saves timeline"
            timelinesRepository -> timelinesDatabase "timelines table"
            timelinesDatabase -> timelinesRepository "Returns"
            timelinesRepository -> followersTimelineUpdater "Returns"
            autoLayout lr
        }

        dynamic timelinesApiApp "TimelinesApiQueryInfluencerPostsInTimeline" {
            title "Follower query influencer posts in the timeline"
            webApp -> getTimelineEndpoint "/timelines/{userId}"
            getTimelineEndpoint -> timelineQuery "Get user timeline by id {userId}"
            timelineQuery -> timelinesRepository "Reads timeline by user id {userId}"
            timelinesRepository -> timelinesDatabase "Reads timelines from table"
            timelinesDatabase -> timelinesRepository "Returns"
            timelinesRepository -> timelineQuery "Returns"
            timelineQuery -> usersClient "Get user influencer folowers"
            usersClient -> usersApiApp "GET /users/{id}/followers?type=influencer"
            usersApiApp -> usersClient "Returns list of influencers"
            usersClient -> timelineQuery "Returns list of influencers"
            timelineQuery -> influencersPostsRepository "if user follows influencers, reads influencer posts"
            influencersPostsRepository -> timelinesDatabase "influencers posts table"
            timelinesDatabase -> influencersPostsRepository "Returns"
            influencersPostsRepository -> timelineQuery "Returns"
            timelineQuery -> getTimelineEndpoint "Returns timeline or if user follows influencers, returns aggregated timeline with influencers posts"
            getTimelineEndpoint -> webApp "Returns timeline"
            autoLayout rl
        }

        deployment * development "DeploymentDevelopment" "Deployment Development environment" {
            include *
            autoLayout lr
        }

        deployment * production "DeploymentProduction" "Deployment Production environment" {
            include *
            autoLayout lr
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
