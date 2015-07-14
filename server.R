
require(likert)
require(reshape)
require(devtools)
require(shiny)
mylevels <- c('Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree')
items3 <- mydata[,substr(names(mydata), 1,2) == 'QU']
head(items3); ncol(items3)
str(items3)
tryCatch({
# This will throw an error because all the items must have the same number of levels.
lbad <- likert(items3)
}, error=function(e) {
print("This is good that an error was thrown!")
print(e)
})
sapply(items3, class) #Verify that all the columns are indeed factors
sapply(items3, function(x) { length(levels(x)) } ) # The number of levels in each factor
for(i in seq_along(items3)) {
items3[,i] <- factor(items3[,i], levels=mylevels)
}
First_Survey<- likert(items3)
First_Survey
plot(First_Survey)
Department <- likert(items3, grouping = mydata$Department)
plot(Department)
Year <- likert(items3, grouping = mydata$Year)
plot(Year)
Aggregate<- likert(items3)
plot(Aggregate)

# Define server logic
shinyServer(function(input, output) {
# Return the requested dataset #TODO have this switch between pisa items
datasetInput <- reactive({
switch(input$dataset,
"Aggregate" = Aggregate,
"Department" = Department,
"Year" = Year)
})
# Generate a summary of the dataset
output$summary <- renderPrint({
dataset <- datasetInput()
summary(dataset,
center=input$center,
ordered=input$ordered)
})
output$print<-renderTable({
dataset<-datasetInput()
print(dataset)
})
#   output$table<-renderTable({
#     dataset<-datasetInput()
#     xtab<-xtable(dataset)
#     print(xtab, include.rownames=FALSE)
#   })
#   output$table<-renderTable({
#     datasetInput()
#   },
#                             caption=input$caption,
#                             include.rownames=FALSE,
#                             include.n=input$include.n,
#                             include.mean=input$include.mean,
#                             include.sd=input$include.sd,
#                             include.low=input$include.low,
#                             include.neutral=input$include.neutral,
#                             include.high=input$include.high,
#                             include.missing=input$include.missing
#                             #include.levels=input$include.levels
#                             )
output$table<-renderTable({
dataset <- datasetInput()
xtab<-xtable(dataset,
caption=input$caption,
include.n=input$include.n,
include.mean=input$include.mean,
include.sd=input$include.sd,
include.low=input$include.low,
include.neutral=input$include.neutral,
include.high=input$include.high,
include.missing=input$include.missing,
center=input$center,
ordered=input$ordered
#include.levels=input$include.levels
)
xtab
})
#add ,caption.placement='top',include.rownames=FALSE
output$plot <- renderPlot({
dataset <- datasetInput()
p<-plot(dataset,

centered=input$centered,
ordered=input$ordered,
center=input$center
)
print(p)
})
})
