
  library(dplyr)
  library(ggplot2)
  
  ModelAnalysisPlot=function(trace_path,Stoch = F,print=T){
    
    trace <-read.csv(trace_path,sep = "")
    n_sim_tot<-table(trace$Time)
    n_sim <- n_sim_tot[1]
    time_delete<-as.numeric(names(n_sim_tot[n_sim_tot!=n_sim_tot[1]]))
    
    if(length(time_delete)!=0) trace = trace[which(trace$Time!=time_delete),]
    
    trace$ID <- rep(1:n_sim[1],each = length(unique(trace$Time)) )
    
    trace.final <-  lapply(colnames(trace)[-which( colnames(trace)%in% c("ID","Time"))],function(c){
      return(data.frame(V=trace[,c], ID = trace$ID,Time=trace$Time,Compartment=c ) )
    })
    trace.final <- do.call("rbind",trace.final)
    
    
    plI<-ggplot( )+
      geom_line(data=trace,
                aes(x=Time,y=I,group=ID))+
      theme(axis.text=element_text(size=18),
            axis.title=element_text(size=20,face="bold"),
            legend.text=element_text(size=18),
            legend.title=element_text(size=20,face="bold"),
            legend.position="right",
            legend.key.size = unit(1.3, "cm"),
            legend.key.width = unit(1.3,"cm") )+
      labs(x="Days", y="I")
    
    plS<-ggplot( )+
      geom_line(data=trace,
                aes(x=Time,y=S,group=ID))+
      theme(axis.text=element_text(size=18),
            axis.title=element_text(size=20,face="bold"),
            legend.text=element_text(size=18),
            legend.title=element_text(size=20,face="bold"),
            legend.position="right",
            legend.key.size = unit(1.3, "cm"),
            legend.key.width = unit(1.3,"cm") )+
      labs(x="Days", y="S")
    
    plR<-ggplot( )+
      geom_line(data=trace,
                aes(x=Time,y=R,group=ID))+
      theme(axis.text=element_text(size=18),
            axis.title=element_text(size=20,face="bold"),
            legend.text=element_text(size=18),
            legend.title=element_text(size=20,face="bold"),
            legend.position="right",
            legend.key.size = unit(1.3, "cm"),
            legend.key.width = unit(1.3,"cm") )+
      labs(x="Days", y="R")
    
    if(Stoch){
      meanTrace <- trace %>% group_by(Time) %>%
        summarise(S=mean(S),I=mean(I),R=mean(R))
      
      meanTrace.final <-  lapply(colnames(meanTrace)[-which( colnames(meanTrace)=="Time")],function(c){
        return(data.frame(V=unlist(meanTrace[,c]), Time=meanTrace$Time,Compartment=c ) )
      })
      meanTrace.final <- do.call("rbind",meanTrace.final)
      
      trace.final$Compartment = factor(trace.final$Compartment, levels = c("S", "I", "R"))
      meanTrace.final$Compartment = factor(meanTrace.final$Compartment, levels = c("S", "I", "R"))
      plAll <-ggplot()+
        geom_line(data=trace.final,
                  aes(x=Time,y=V, group=ID))+
        # Mean line for S
        geom_line(data = subset(meanTrace.final, Compartment == "S"),
                  aes(x = Time, y = V),
                  color = "green", linetype = "dashed") +
        facet_grid(~Compartment)+
        # Mean line for I
        geom_line(data = subset(meanTrace.final, Compartment == "I"),
                  aes(x = Time, y = V),
                  color = "red", linetype = "dashed") +
        # Mean line for R
        geom_line(data = subset(meanTrace.final, Compartment == "R"),
                  aes(x = Time, y = V),
                  color = "purple", linetype = "dashed") +
        theme(axis.text=element_text(size=15),
              axis.title=element_text(size=15,face="bold"),
              legend.text=element_text(size=18),
              legend.title=element_text(size=18,face="bold"),
              legend.position="bottom",
              legend.key.size = unit(1, "cm"),
              legend.key.width = unit(1,"cm") )+
        labs(x="Days", y="Population")
      
      meanTrace.final$Compartment = factor(meanTrace.final$Compartment, levels = c("S", "I", "R"))
      plAllMean <-ggplot( )+
        geom_line(data=meanTrace.final,
                  aes(x=Time,y=V,col=Compartment),
                  linetype="dashed")+
        scale_color_manual(values = c("green", "red", "purple"))+
        theme(axis.text=element_text(size=18),
              axis.title=element_text(size=20,face="bold"),
              legend.text=element_text(size=18),
              legend.title=element_text(size=20,face="bold"),
              legend.position="right",
              legend.key.size = unit(1.3, "cm"),
              legend.key.width = unit(1.3,"cm") )+
        labs(x="Days", y="Mean Population")
      
      plIdens<-ggplot(trace[trace$Time==max(trace$Time),])+
        geom_histogram(aes(I))+
        theme(axis.text=element_text(size=18),
              axis.title=element_text(size=20,face="bold"),
              legend.text=element_text(size=18),
              legend.title=element_text(size=20,face="bold"),
              legend.position="right",
              legend.key.size = unit(1.3, "cm"),
              legend.key.width = unit(1.3,"cm") )
      
      plSdens<-ggplot(trace[trace$Time==max(trace$Time),])+
        geom_histogram(aes(S))+
        theme(axis.text=element_text(size=18),
              axis.title=element_text(size=20,face="bold"),
              legend.text=element_text(size=18),
              legend.title=element_text(size=20,face="bold"),
              legend.position="right",
              legend.key.size = unit(1.3, "cm"),
              legend.key.width = unit(1.3,"cm") )
      
      plRdens<-ggplot(trace[trace$Time==max(trace$Time),])+
        geom_histogram(aes(R))+
        theme(axis.text=element_text(size=18),
              axis.title=element_text(size=20,face="bold"),
              legend.text=element_text(size=18),
              legend.title=element_text(size=20,face="bold"),
              legend.position="right",
              legend.key.size = unit(1.3, "cm"),
              legend.key.width = unit(1.3,"cm") )
      
      plI<-plI+
        geom_line(data=meanTrace,
                  aes(x=Time,y=I,col="Mean"),
                  linetype="dashed")+
        labs(x="Days", y="I",col="")
      
      plS<-plS+
        geom_line(data=meanTrace,
                  aes(x=Time,y=S,col="Mean"),
                  linetype="dashed")+
        labs(x="Days", y="S",col="")
      
      plR<-plR+
        geom_line(data=meanTrace,
                  aes(x=Time,y=R,col="Mean"),
                  linetype="dashed")+
        labs(x="Days", y="R",col="")
      
      ListReturn<-list(plS = plS,plI = plI,plR = plR,
                       HistS = plSdens,HistI = plIdens,HistR = plRdens,
                       plAll=plAll,plAllMean=plAllMean)
    }else{
      trace.final$Compartment = factor(trace.final$Compartment, levels = c("S", "I", "R"))
      plAll <-ggplot( )+
        geom_line(data=trace.final,
                  aes(x=Time,y=V,col=Compartment))+
        scale_color_manual(values = c("green", "red", "purple"))+
        theme(axis.text=element_text(size=18),
              axis.title=element_text(size=20,face="bold"),
              legend.text=element_text(size=18),
              legend.title=element_text(size=20,face="bold"),
              legend.position="right",
              legend.key.size = unit(1.3, "cm"),
              legend.key.width = unit(1.3,"cm") )+
        labs(x="Days", y="Population")
      ListReturn<-list(plS = plS,plI = plI,plR = plR,plAll=plAll)
    }
    
    if(print){
      for(j in 1:length(ListReturn))
        print(ListReturn[j])
    }
    
    return(ListReturn)
  }
  