Plan
====

How to proceed in creating the iOS app? 

Current goal/status:

 - Create data model classes, maybe tests, and get JSON data retrieval working,
 with code to convert JSON code to data models.

Goals:

 - App should be *well-coded*. Don't want to just hack this together. If I take
 my time and code it well, it will be much easier to do updates in the future.
 - Testing?! Try to at least have some unit tests, if possible.


Steps:

 - Define data model 
    - Do this on paper or in text file first
    - Define all models I can think of
    - Define all fields and methods I could think of for each mode
    - Convert this to actual model classes
    - Write unit tests for models
 - Figure out how to use API/JSON as data source. How does it fit 
 in with data models and everything else?
 - Create storyboards/views
    - Start with iPhone
    - Eventually do iPad too (After I figure things out!)
    - Hook up interface elements with code (may overlap with next step)
 - View controllers
    - Setup main navigation controller and list/map views
      - To start, work on list view! Create map view but don't hook it up
      until list/detail view is working. Map view may even be able to wait
      until after launch of MVP! (Can get my feet wet by having a map on the
      establishment detail view.)
    - Get the base app working before doing too much customization of views,
    but eventually:
      - Create custom table view list item view and other applicable views
 - Sometime:
    - Think about design of app
      - Find/create icon(s)
      - Work on look and feel of app. Drop shadows, etc.
    - What else?

Data Models
-----------

For each data model, specify properties and methods.

DinesafeEstablishment

- Properties
    - id
        - NSNumber (?)
    - latest_name
        - NSString
    - latest_type
        - NSString
    - address
        - NSString
    - lat / lng
        - How to represent this in obj-c?
        - CLLocationDegrees
        - CLLocationCoordinate2D ? 
    - inspections
- Methods
    -

DinesafeInspection

 - Properties
    - STATUSES
        - Constant, holds options for statuses
          - Pass, Conditional Pass, Closed, Out of Business
    - status
        - 
    - minimum_inspections_per_year
        -
    - date
        -
    - establishment_name
        -
    - establishment_type
        -
 - Methods
    - 

DinesafeInfraction

 - Properties
    - details
        - NSString
    - severity
        - 
    - action
        -
    - court_outcome
        -
    - amount_fined
        -
 - Methods
    - 



ViewControllers
---------------


DinesafeViewController

- Main ViewController
    - Holds Navigation Controller (top bar)
    - Loads Other view as necessary:
        - table view 
        - map view
