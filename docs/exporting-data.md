# Exporting data

You should use `exportTaskData(taskName, fileOut)`. Note that this makes assumption about where you’re calling the function from (the root of your PsychTaskFramework instance) and where your data is stored (in the folder `tasks/taskName/data`). 

If you wish to extract the data for a single subject, you can use the function `exportSubject(DataObject, fileOut)`, which is what `exportTaskData` uses under the hood.

This exports all collected data, including the rather unwieldy date form. To clean up the data, you might find RNA-Analysis-Toolbox helpful.