library(shiny)
library(ggplot2)
library(lattice)
library(caret)
library(AppliedPredictiveModeling)
library(rpart)
library(stabs)
library(parallel)
library(mboost)
library(randomForest)
library(e1071)

data("GermanCredit")
data(AlzheimerDisease)
Alzheimer <- cbind(diagnosis, predictors)
data("segmentationData")

#sort out the factor data in germancredit

for (x in names(GermanCredit)) {
    if (length(unique(GermanCredit[,x]))==2) {
        GermanCredit[,x] <- factor(GermanCredit[,x])
    }
}

# Define server logic
shinyServer(function(input, output) {
    usingData <- reactive({
        switch(input$dataset,
        "alz" = Alzheimer,
        "gcred"=GermanCredit,
        "cellseg"=segmentationData)
    })
    
    classVar <- reactive({
        switch(input$dataset,
               "alz" = Alzheimer$diagnosis,
               "gcred"=GermanCredit$Class,
               "cellseg"=segmentationData$Class)
    })
    
    classStr <- reactive({
        switch(input$dataset,
               "alz" = "diagnosis",
               "gcred"="Class",
               "cellseg"="Class")
    })
 
    myTrControl <- reactive({
        if (input$trainMethod =="repeatedcv")
            trainControl(method=input$trainMethod,
                         number=input$resno,
                         repeats=input$repno)
        else
            trainControl(method=input$trainMethod,
                         number=input$resno)
    })
    
    splitVect <- reactive({
        set.seed(input$myseed)
        createDataPartition(classVar(),p=input$trainpct,list=FALSE)
    })
    
    trainData <- reactive(usingData()[splitVect(),])
    
    testData <- reactive(usingData()[-splitVect(),])
    
    trainedModel <- reactive({
        set.seed(input$myseed)
        myForm <- as.formula(paste(classStr(),".",sep="~"))
        myPre <- NULL
        if (input$preproc) myPre <- "pca"
        
        if (input$mdltype=="glm") {
            train(myForm,
                  data=trainData(), 
                  method=input$mdltype,
                  family=binomial(),
                  trControl = myTrControl(),
                  preProcess = myPre)
        }
        else {
            train(myForm,
                  data=trainData(), 
                  method=input$mdltype,
                  trControl = myTrControl(),
                  preProcess = myPre) 
        }
    })
    
    confMatrix <-reactive(
        confusionMatrix(predict(trainedModel(),testData()),
                        testData()[,classStr()])
    )
    
    ## Training Time
    output$trainingTime <- renderText({
        if (input$gobutton==0)
            return("Uninitialized")
        input$gobutton
        isolate(round(trainedModel()$times$everything[[3]],2))
    })
    
    ## Training Accuracy Estimate
    output$cvAccEst <- renderText({
        if (input$gobutton==0)
            return("Uninitialized")
        input$gobutton
        isolate(round(mean(trainedModel()$resample$Accuracy),4))
    })
    
    ## Training Kappa Estimate
    output$cvKappaEst <- renderText({
        if (input$gobutton==0)
            return("Uninitialized")
        input$gobutton
        isolate(round(mean(trainedModel()$resample$Kappa),4))
    })
    
    output$cvPlot <- renderPlot({
        if (input$gobutton==0)
            return()
        input$gobutton
        isolate({
            resDF <- rbind(
                data.frame(
                    "score" = trainedModel()$resample$Accuracy,
                    "type"=rep("Accuracy",length(
                        trainedModel()$resample$Accuracy
                    ))
                ),
                data.frame(
                    "score" = trainedModel()$resample$Kappa,
                    "type"=rep("Kappa",length(
                        trainedModel()$resample$Kappa
                    ))
                )
            )
            myplot <- ggplot(resDF,aes(type,score))
            myplot <- myplot + geom_boxplot(aes(fill=type))
            myplot <- myplot + guides(fill=FALSE)
            myplot <- myplot + labs(title="Resampling Accuracy by Measure",
                                    x="measure")
            myplot
        })
    })
    
    ## Test Accuracy
    output$testAcc <- renderText({
        if (input$gobutton==0)
            return("Uninitialized")
        input$gobutton
        isolate(round(confMatrix()$overall[[1]],4))
    })
    
    ## Test Kappa
    
    output$testKapp <- renderText({
        if (input$gobutton==0)
            return("Uninitialized")
        input$gobutton
        isolate(round(confMatrix()$overall[[2]],4))
    })
    
    output$model <- renderPrint({
        if (input$gobutton==0)
            return("Uninitialized")
        input$gobutton
        isolate(trainedModel())
    })
    
    
    output$cm <- renderPrint({
        if (input$gobutton==0)
            return("Uninitialized")
        input$gobutton
        isolate(confMatrix())
    })
    
    
    
    
})
