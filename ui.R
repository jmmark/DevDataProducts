library(shiny)

# Define UI for project application
shinyUI(fluidPage(
    
    # Application title
    headerPanel("Exploring Machine Learning"),
    
    p(a("Machine learning",href="https://en.wikipedia.org/wiki/Machine_learning"),
      " is a wide and varied field that is more useful than it has ever been.  This app allows the user
      to play with various choices one needs to make when developing a machine
      learning model and see the impact on that models predictive ability"),
    
    p("Use the controls on the left to choose options
      for training a machine-learning model using the caret package in R on one of 
      several built-in datasets.  More information is provided 
      with the controls where needed"),  
    
    p("Press the Go! button at the bottom and results will
      be shown in the tabs to the right.  Several different types of results
      are shown, including model training time and accuracy.  Explanations are
      provided in the tab where needed.  Values will be blank or unititialized if a
      model has not yet been run using the Go! button"),
    
    p("The server.R and ui.R files for this app can be found at ",
      a("this github repo", href="https://github.com/jmmark/DevDataProducts.git", target="_blank")),
    
    sidebarPanel(h2("Controls"),
        selectInput("dataset","Choose Dataset:",
                    list("Alzheimer Data" = "alz",
                         "German Credit Data" = "gcred",
                         "Cell Body Segmentation" = "cellseg")),
        helpText("More info on",
                 a(" Alzheimer Data,",href="http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0018850#s5", target="_blank"),
                 a(" German Credit Data,",href="http://topepo.github.io/caret/datasets.html", target="_blank"),
                 "or",
                 a(" Cell Body Segmentation.", href="http://topepo.github.io/caret/datasets.html", target="_blank")
        ),
        
        selectInput("mdltype","Choose Modeling Method:",
                     list("Generalized Linear Model (GLM)" = "glm",
                          "Classification Tree" = "rpart",
                          "Boosted GLM" = "glmboost",
                          "Random Forest" = "rf")),
        
        helpText("More info on",
                 a(" GLM, ",href="https://en.wikipedia.org/wiki/Generalized_linear_model", target="_blank"),
                 a(" Trees,",href="https://en.wikipedia.org/wiki/Decision_tree_learning", target="_blank"),
                 a(" Boosting,",href="https://en.wikipedia.org/wiki/Boosting_%28machine_learning%29", target="_blank"),
                 "or",
                 a(" Random Forest.",href="https://en.wikipedia.org/wiki/Random_forest", target="_blank")),
        checkboxInput("preproc", "Pre-process predictors"),
        
        helpText("If checked, pre-process predictors using ",
                 a("Principal Component Analysis",
                   href="https://en.wikipedia.org/wiki/Principal_component_analysis", target="_blank")),
        
        selectInput("trainMethod","Choose Resampling Method:",
                     list("Bootstrapping"="boot",
                          "K-Folds Cross-Validation"="cv",
                          "Repeated K-Folds" = "repeatedcv"),
                    selected="cv"),
        
        helpText(a("More info",href="http://appliedpredictivemodeling.com/blog/2014/11/27/08ks7leh0zof45zpf5vqe56d1sahb0", target="_blank"),
                 " on cross-validation vs bootstrap resampling"),
        
        sliderInput("resno","Choose Number of Resamples",
                    min=5,max=25,value=10),
        

        conditionalPanel(condition="input.trainMethod=='repeatedcv'",
                         sliderInput("repno","Choose Number of Repeats",
                                     min=1,max=10,value=2)),
        
        sliderInput("trainpct","Fraction of Dataset to Allocate to Training:",
                    min=.6,max=.8,value=.7),
        
        helpText("This portion of the data will be used to 
                 train the model.  The remainder will be reserved to
                 test its predictive power on external data"),
        
        numericInput("myseed","Set Random Seed",
                     value=1416,step=1),
        
       
        
        helpText("Setting a seed allows later replication"),
        actionButton("gobutton","Go!")
        
    ),
    
    mainPanel(
        
        tabsetPanel(
            tabPanel("Summary",
                    h4("Model Training Time, Seconds:"),
                    textOutput("trainingTime"),
                    h4("Estimated out-of-sample prediction accuracy:"),
                    textOutput("cvAccEst"),
                    h4("Estimated out-of-sample prediction ",
                       a("kappa:",href="https://en.wikipedia.org/wiki/Cohen's_kappa", target="_blank")),
                    textOutput("cvKappaEst"),
                    h4("Prediction accuracy on the test set:"),
                    textOutput("testAcc"),
                    h4("Prediction kappa on the test set:"),
                    textOutput("testKapp")
            ),
            tabPanel("Trained Model",
                     h5("R output of model training results"),
                     verbatimTextOutput("model")
            ),
            
            tabPanel("Training Resamples Graph",
                     h5("Range of accuracy and kappa found using resampling
                         during the model training process"),
                    plotOutput("cvPlot")
            ),
            tabPanel("Test Results",
                     h5(a("Confusion Matrix", 
                          href="https://en.wikipedia.org/wiki/Confusion_matrix", target="_blank"),
                        "showing the predicted vs actual classification in the test set"),
                verbatimTextOutput("cm")
            )
        )
    )
    
    
))
