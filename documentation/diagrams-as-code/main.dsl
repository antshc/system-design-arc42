/*
 * This is a combined version of the following workspaces:
 *
 * - "Big Bank plc - System Landscape" (https://structurizr.com/share/28201/)
 * - "Big Bank plc - Internet Banking System" (https://structurizr.com/share/36141/)
*/
workspace "highly-scalable-image-sharing-platform" "This is an example workspace to illustrate system design as code approach" {

    model {
        user = person "User" "A registered user of the image sharing platform." "User"

        group "Image sharing platform" {
            // supportStaff = person "Customer Service Staff" "Customer service staff within the bank." "Bank Staff"
            // backoffice = person "Back Office Staff" "Administration and support staff within the bank." "Bank Staff"
            
            storage = softwaresystem "Azure storage" "Uses to store users images." "Existing System"
            googleauth = softwaresystem "Google auth system" "Uses to authenticate users with google account." "Existing System"
            
            // mainframe = softwaresystem "Mainframe Banking System" "Stores all of the core banking information about customers, accounts, transactions, etc." "Existing System"
            // email = softwaresystem "E-mail System" "The internal Microsoft Exchange e-mail system." "Existing System"
            // atm = softwaresystem "ATM" "Allows customers to withdraw cash." "Existing System"

            imageSharingPlatform = softwaresystem "Image sharing system" "Social network system, where user can share images, follow other people." {
                 webApp = container "Web GUI" "Provides all of the image sharing platform functionality to users via their web browser." "Angular" "Web Browser"
                 postsApiApp = container "Posts API" "Provides posts managament functionality via a JSON/HTTPS API." "ASP .NET API, C#"
                 postsDatabase = container "Posts Database" "Manage user posts, stores images urls." "NoSQL Document Schema" "Database"
                
                // mobileApp = container "Mobile App" "Provides a limited subset of the Internet banking functionality to customers via their mobile device." "Xamarin" "Mobile App"
                // webApplication = container "Web Application" "Delivers the static content and the Internet banking single page application." "Java and Spring MVC"
                //     signinController = component "Sign In Controller" "Allows users to sign in to the Internet Banking System." "Spring MVC Rest Controller"
                //     accountsSummaryController = component "Accounts Summary Controller" "Provides customers with a summary of their bank accounts." "Spring MVC Rest Controller"
                //     resetPasswordController = component "Reset Password Controller" "Allows users to reset their passwords with a single use URL." "Spring MVC Rest Controller"
                //     securityComponent = component "Security Component" "Provides functionality related to signing in, changing passwords, etc." "Spring Bean"
                //     mainframeBankingSystemFacade = component "Mainframe Banking System Facade" "A facade onto the mainframe banking system." "Spring Bean"
                //     emailComponent = component "E-mail Component" "Sends e-mails to users." "Spring Bean"
                // }
            }
        }

        # relationships between people and software systems
        user -> imageSharingPlatform "Publish image, search users, follow other users, read posts from the timeline "
        imageSharingPlatform -> storage "Manage images"
        imageSharingPlatform -> googleauth "Registration, authentication" 
        
        // imageSharingPlatform -> mainframe "Gets account information from, and makes payments using"
        // imageSharingPlatform -> email "Sends e-mail using"
        // email -> user "Sends e-mails to"
        // user -> supportStaff "Asks questions to" "Telephone"
        // supportStaff -> mainframe "Uses"
        // user -> atm "Withdraws cash using"
        // atm -> mainframe "Uses"
        // backoffice -> mainframe "Uses"

        # relationships to/from containers
        user -> webApp "Visits fancy-pics.com/web using." "HTTPS"
        webApp -> postsApiApp "Manage user posts." "JSON/HTTPS"
        postsApiApp -> postsDatabase "Manage posts data."
        // user -> webApp "Views account balances, and makes payments using"
        // user -> mobileApp "Views account balances, and makes payments using"
        // webApplication -> webApp "Delivers to the customer's web browser"

        # relationships to/from components
        // webApp -> signinController "Makes API calls to" "JSON/HTTPS"
        // webApp -> accountsSummaryController "Makes API calls to" "JSON/HTTPS"
        // webApp -> resetPasswordController "Makes API calls to" "JSON/HTTPS"
        // mobileApp -> signinController "Makes API calls to" "JSON/HTTPS"
        // mobileApp -> accountsSummaryController "Makes API calls to" "JSON/HTTPS"
        // mobileApp -> resetPasswordController "Makes API calls to" "JSON/HTTPS"
        // signinController -> securityComponent "Uses"
        // accountsSummaryController -> mainframeBankingSystemFacade "Uses"
        // resetPasswordController -> securityComponent "Uses"
        // resetPasswordController -> emailComponent "Uses"
        // securityComponent -> database "Reads from and writes to" "JDBC"
        // mainframeBankingSystemFacade -> mainframe "Makes API calls to" "XML/HTTPS"
        // emailComponent -> email "Sends e-mail using"

        // deploymentEnvironment "Development" {
        //     deploymentNode "Developer Laptop" "" "Microsoft Windows 10 or Apple macOS" {
        //         deploymentNode "Web Browser" "" "Chrome, Firefox, Safari, or Edge" {
        //             developerwebAppInstance = containerInstance webApp
        //         }
        //         deploymentNode "Docker Container - Web Server" "" "Docker" {
        //             deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
        //                 developerWebApplicationInstance = containerInstance webApplication
        //                 developerApiApplicationInstance = containerInstance apiApplication
        //             }
        //         }
        //         deploymentNode "Docker Container - Database Server" "" "Docker" {
        //             deploymentNode "Database Server" "" "Oracle 12c" {
        //                 developerDatabaseInstance = containerInstance database
        //             }
        //         }
        //     }
        //     deploymentNode "Big Bank plc" "" "Big Bank plc data center" "" {
        //         deploymentNode "bigbank-dev001" "" "" "" {
        //             softwareSystemInstance mainframe
        //         }
        //     }

        // }

        // deploymentEnvironment "Live" {
        //     deploymentNode "Customer's mobile device" "" "Apple iOS or Android" {
        //         liveMobileAppInstance = containerInstance mobileApp
        //     }
        //     deploymentNode "Customer's computer" "" "Microsoft Windows or Apple macOS" {
        //         deploymentNode "Web Browser" "" "Chrome, Firefox, Safari, or Edge" {
        //             livewebAppInstance = containerInstance webApp
        //         }
        //     }

        //     deploymentNode "Big Bank plc" "" "Big Bank plc data center" {
        //         deploymentNode "bigbank-web***" "" "Ubuntu 16.04 LTS" "" 4 {
        //             deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
        //                 liveWebApplicationInstance = containerInstance webApplication
        //             }
        //         }
        //         deploymentNode "bigbank-api***" "" "Ubuntu 16.04 LTS" "" 8 {
        //             deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
        //                 liveApiApplicationInstance = containerInstance apiApplication
        //             }
        //         }

        //         deploymentNode "bigbank-db01" "" "Ubuntu 16.04 LTS" {
        //             primaryDatabaseServer = deploymentNode "Oracle - Primary" "" "Oracle 12c" {
        //                 livePrimaryDatabaseInstance = containerInstance database
        //             }
        //         }
        //         deploymentNode "bigbank-db02" "" "Ubuntu 16.04 LTS" "Failover" {
        //             secondaryDatabaseServer = deploymentNode "Oracle - Secondary" "" "Oracle 12c" "Failover" {
        //                 liveSecondaryDatabaseInstance = containerInstance database "Failover"
        //             }
        //         }
        //         deploymentNode "bigbank-prod001" "" "" "" {
        //             softwareSystemInstance mainframe
        //         }
        //     }

        //     primaryDatabaseServer -> secondaryDatabaseServer "Replicates data to"
        // }
    }

    views {
        systemlandscape "SystemLandscape" {
            include *
            autoLayout
        }

        systemcontext imageSharingPlatform "SystemContext" {
            include *
            animation {
                imageSharingPlatform
                user
                storage
                googleauth
            }
            autoLayout
        }

        container imageSharingPlatform "Containers" {
            include *
            animation {
                webApp
                postsApiApp
                postsDatabase
            }
            autoLayout
        }

        // component apiApplication "Components" {
        //     include *
        //     animation {
        //         webApp mobileApp database email mainframe
        //         signinController securityComponent
        //         accountsSummaryController mainframeBankingSystemFacade
        //         resetPasswordController emailComponent
        //     }
        //     autoLayout
        // }

        // dynamic apiApplication "SignIn" "Summarises how the sign in feature works in the single-page application." {
        //     webApp -> signinController "Submits credentials to"
        //     signinController -> securityComponent "Validates credentials using"
        //     securityComponent -> database "select * from users where username = ?"
        //     database -> securityComponent "Returns user data to"
        //     securityComponent -> signinController "Returns true if the hashed password matches"
        //     signinController -> webApp "Sends back an authentication token to"
        //     autoLayout
        // }

        // deployment imageSharingPlatform "Development" "DevelopmentDeployment" {
        //     include *
        //     animation {
        //         developerwebAppInstance
        //         developerWebApplicationInstance developerApiApplicationInstance
        //         developerDatabaseInstance
        //     }
        //     autoLayout
        // }

        // deployment imageSharingPlatform "Live" "LiveDeployment" {
        //     include *
        //     animation {
        //         livewebAppInstance
        //         liveMobileAppInstance
        //         liveWebApplicationInstance liveApiApplicationInstance
        //         livePrimaryDatabaseInstance
        //         liveSecondaryDatabaseInstance
        //     }
        //     autoLayout
        // }

        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "User" {
                background #08427b
            }
            element "Bank Staff" {
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