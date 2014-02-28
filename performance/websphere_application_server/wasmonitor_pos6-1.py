'''
Created on Dec 11, 2009

@author: Diogenes Buarque Ianakiara
@e-mail: diogenes.buarque@inmetrics.com.br

@author: Guilherme Botelho Diniz Junqueira
@e-mail: guilherme.junqueira@inmetrics.com.br
@version 2.5
'''
#-------------------------------------------------------------------------
# Este programa deve se utilizado para coletar metricas do websphere 6.1
# wasmonitor.py - Jython implementation 
#-------------------------------------------------------------------------

import sys
import os
import re
from time import sleep
from java.util import Date
from java.text import SimpleDateFormat
from java.lang import String
from java.util.regex import *
from java.lang import *
from com.ibm.websphere.pmi.stat import *;

#------- Global variables ------
DAY_FORMAT  = SimpleDateFormat('yyyy-MM-dd')   #Ex: 2010-03-07
HOUR_FORMAT = SimpleDateFormat('HH:mm:ss')     #Ex: 23:00:00

#  Metodo que coleta as metricas do websphere apartir dos parametros
def wasMonitor(serverName, cellName, nodeName, module):
    #global AdminConfig
    global AdminControl

    # Informacoes de perfil
    try:
        perfName = AdminControl.completeObjectName ('process='+serverName+',node='+nodeName+',type=Perf,*')
        perfOName = AdminControl.makeObjectName (perfName)
	    # "Altera o level de coleta do PMI para BASIC
	    #configParams = ['basic']
	    #configSigs  = ['java.lang.String']
	    #AdminControl.invoke_jmx (perfOName, 'setStatisticSet', configParams, configSigs)
    except Error, e:
	    processLogErrors(ERROR_FILE, "Erro ao criar o objeto AdminControl: verifique se o PMI está ativado!")
	    processLogErrors(ERROR_FILE, e)	
    #info server
    srvInfo = AdminControl.completeObjectName ("type=Server,name="+serverName+",cell="+cellName+",node="+nodeName+",*")
    try:	
        params = [AdminControl.makeObjectName(srvInfo), java.lang.Boolean ('true')]
        sigs = ['javax.management.ObjectName','java.lang.Boolean']
        statObj = AdminControl.invoke_jmx (perfOName, 'getStatsObject', params, sigs)
        statsArrayParser(serverName, cellName, nodeName, statObj, module, "true")
    except Error,e:
        processLogErrors(ERROR_FILE, "Erro ao obter objetos do WebSphere para obtencao das coletas de metricas")

# Metodo que tem por objetivo realizar o parse das informacoes retornadas pelo Websphere
# Diferente do metodo genericModuleParser, este metodo recebe um array como parametro
def statsArrayParser(serverName, cellName, nodeName, statObj, module, checkModuleName):
    writeStatistcs(serverName, cellName, nodeName, statObj, module)
    subStats = statObj.getSubStats()
    if(len(subStats) > 0):
        if(checkModuleName == "true"):
            for ss in subStats:
                if(ss.getName() == module):
                   statsArrayParser(serverName, cellName, nodeName, ss, module, "false")
        elif(checkModuleName == "false"):
            for ss in subStats:
                statsArrayParser(serverName, cellName, nodeName, ss, module, "false")

#http://publib.boulder.ibm.com/infocenter/dmndhelp/v6rxmx/index.jsp?topic=/com.ibm.wsps.602.javadoc.doc/doc/com/ibm/websphere/pmi/stat/WSStatistic.html
def writeStatistcs(serverName, cellName, nodeName, statObj, module):
    statistics = statObj.getStatistics()
    if(len(statistics) > 0 ):
        for st in statistics:
            output = {"Server": serverName, "Cell": cellName, "Node": nodeName}
            output["StatObj"] = statObj.getName()
            output["StatisticName"] = st.getName()
            output["StartTime"] = str(st.getStartTime())
            output["LastSampleTime"] = str(st.getLastSampleTime())
            if(isinstance(st, WSAverageStatistic)):
                output["Count"] = str(st.getCount())
                output["Max"] = str(st.getMax())
                output["Mean"] = str(st.getMean())
                output["Min"] = str(st.getMin())
                output["SumOfSquares"] = str(st.getSumOfSquares())
                output["Total"] = str(st.getTotal())
                if(isinstance(st, WSTimeStatistic)):
                    output["MinTime"] = str(st.getMinTime())
                    output["MaxTime"] = str(st.getMaxTime())
                    output["TotalTime"] = str(st.getTotalTime())
            elif(isinstance(st, WSBoundaryStatistic)):            
                output["LowerBoundary"] = str(st.getLowerBound())
                output["UpperBoundary"] = str(st.getUpperBound())
                if(isinstance(st, WSBoundedRangeStatistic)):
                    output["Current"] = str(st.getCurrent())
                    output["HighWaterMark"] = str(st.getHighWaterMark())
                    output["Integral"] = str(st.getIntegral())
                    output["LowWaterMark"] = str(st.getLowWaterMark())
                    output["Mean"] = str(st.getMean())
            elif(isinstance(st, WSRangeStatistic)):
                output["Current"] = str(st.getCurrent())
                output["HighWaterMark"] = str(st.getHighWaterMark())
                output["Integral"] = str(st.getIntegral())
                output["LowWaterMark"] = str(st.getLowWaterMark())
                output["Mean"] = str(st.getMean())
                # Not sure if this is needed
                if(isinstance(st, WSBoundedRangeStatistic)):
                    output["LowerBoundary"] = str(st.getLowerBound())
                    output["UpperBoundary"] = str(st.getUpperBound())
            elif(isinstance(st, WSCountStatistic)):
                output["Count"] = str(st.getCount())
            elif(isinstance(st, WSDoubleStatistic)):
                output["Double"] = str(statObj.getDouble())
            else:
                processLogErrors(ERROR_FILE, "Error processing statObject " + output["StatObj"] + " for " + output["StatObj"] + " statistic.")
                processLogErrors(ERROR_FILE, "Unknown statistic type: " + type(st))
            #Contatena hora de processamento
            now = Date()
            output["Date"] = DAY_FORMAT.format(now)
            output["Hour"] = HOUR_FORMAT.format(now)
            fullFileName =  os.path.join(OUTPUT_PATH, output["Date"] + "_" + module + "_" + output["StatisticName"] + "_metricLog.csv")
            writeDictionaryToFile(output, fullFileName)
 
def writeDictionaryToFile(dict, filez):
    try:
        # If the file exists, we do not need to write the header
        if (os.path.isfile(filez)):
            # Abre o arquivo em modo append
            outfile = open(filez, 'a')
            outfile.write("\"" + "\";\"".join(dict.values()) + "\"\n")
        else:
            # Abre o arquivo em modo write
            outfile = open(filez, 'w')
            outfile.write("\"" + "\";\"".join(dict.keys()) + "\"\n")
            outfile.write("\"" + "\";\"".join(dict.values()) + "\"\n")
        outfile.close()
    except Error,e:
        processLogErrors(ERROR_FILE, e)
        outfile.close()
        pass

# Recebe path de arquivo de log para registrar falhas nas coletas e eventuais excecoes
def processLogErrors(fullFileName, log):
    try:
        if (os.path.isfile(fullFileName)):
            # Abre o arquivo em modo append
            outLogFile = open(fullFileName, 'a') 
            outLogFile.write(log)
        else:
            # Abre o arquivo em modo write
            outLogFile = open(fullFileName, 'w')
            outLogFile.write(log)
        outLogFile.close() # fecha o arquivo
    except Error,e:
        print e
        outLogFile.close() # fecha o arquivo
        pass	
        
# Metodo para obtencao da lista de servidores e nodes e para o processamento das metricas para cada servidor
def processServerMetrics(module):
    global AdminConfig
    #global AdminControl
		
    #Obtem lista de servires do websphere	
    serverNames = AdminConfig.list("Server")
    #vetor com fully qualified name do server
    serversLines = serverNames.split('\n')
    # itera sobre a linha de cada servidor
    for el in serversLines:
        # Pattern para obter servers, cells, nodes
        pSeverName = Pattern.compile("(^([1-zA-Z_0-9]+)\\(cells/([1-zA-Z_0-9]+.?[1-zA-Z_0-9]+)/nodes/([1-zA-Z_0-9]+.?[1-zA-Z_0-9]+)/servers/([1-zA-Z_0-9]+.?[1-zA-Z_0-9]+))")	
        # Matcher que obtem o nome de cada servidor, call e node
        matcherServerInfor = pSeverName.matcher(String(el))
        #verifica se as informacoes foram encontradas pelo regex
        if(matcherServerInfor.find()):
            serverName =  matcherServerInfor.group(2) # Server Name
            cellName   =  matcherServerInfor.group(3) # Cell Name
            nodeName   =  matcherServerInfor.group(4) # Node Name
            # Para nao coletar metricas do httpServer
            #if(not String(serverName).contains(String("webserver")) and not String(serverName).contains(String("http"))  and not String(serverName).contains(String("dmgr"))):
            if(serverName.find("webserver") == -1 and serverName.find("http") == -1 and serverName.find("dmgr") == -1):
                try:
                    wasMonitor(serverName, cellName, nodeName, module)
                except Error, e:
                    processLogErrors(ERROR_FILE, "Erro no processamento de metricas do servidor: "+serverName)
                    processLogErrors(ERROR_FILE, e)	
                    pass	

#-----------------------------------------------------------------------------------------------------------
# Main
#   Obtem lista de tipos de metricas ex: connectionPoolModule, hamanagerModule, objectPoolModule, servletSessionsModule, threadPoolModule
#   srvInfo = AdminControl.completeObjectName ("type=Server,name=server1,node=win-websphereNode01,*")
#	perfName = AdminControl.completeObjectName ('process=server1,node=win-websphereNode01,type=Perf,*')
#	perfOName = AdminControl.makeObjectName (perfName)
#	params = [AdminControl.makeObjectName (srvInfo)]
#	sigs = ['javax.management.ObjectName']
#	AdminControl.invoke_jmx (perfOName, 'listStatMemberNames', params, sigs)
#------------------------------------------------------------------------------------------------------------

if (len(sys.argv) == 2):
    # Diretorio para escrita das metricas coletadas
    global OUTPUT_PATH
    global ERROR_FILE
    splitModules = sys.argv[0].split(',')
    OUTPUT_PATH  = sys.argv[1]
    ERROR_FILE   = os.path.join(OUTPUT_PATH, DAY_FORMAT.format(Date()) + "_errorLog.log")
    for aModule in splitModules:
        # Remove eventuais espacos em branco existentes
        aModule = aModule.lstrip().rstrip()
        processServerMetrics(aModule)
else:
    print "Este script requer dois parametros para sua execucao:"
    print "1 - Lista de modulos para os quais serao extraidas as metricas."
    print "Segue a lista de alguns possiveis modules disponiveis:"
    print " - beanModule,connectionPoolModule,hamanagerModule,objectPoolModule,servletSessionsModule,threadPoolModule,jvmRuntimeModule"
    print " - transactionModule,webAppModule,cacheModule,orbPerfModule,SipContainerModule,systemModule"
    print "Caso dois ou mais modulos precisem ser consultados, os seus nomes devem ser fornecidos separados por virgula"
    print
    print "2 - Diretorio (sem \\ ou / no final) para gravacao dos arquivos de saida"
    print "Exemplo:  \"beanModule,servletSessionsModule\" \"C:\Windows\Temp\""