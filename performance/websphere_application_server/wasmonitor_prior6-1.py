'''
Created on Dec 11, 2009

@author: Diogenes Buarque Ianakiara
@e-mail: diogenes.buarque@inmetrics.com.br

@author: Guilherme Botelho Diniz Junqueira
@e-mail: guilherme.junqueira@inmetrics.com.br
@version 2.2 beta 1
'''
#-------------------------------------------------------------------------
# Este programa deve se utilizado para coletar métricas do websphere 6.1
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

#------- Global variables ------
DAY_FORMAT  = SimpleDateFormat('yyyy-MM-dd')   #Ex: 2010-03-07
HOUR_FORMAT = SimpleDateFormat('HH:mm:ss')     #Ex: 23:00:00

#  Método que coleta as metricas do websphere apartir dos parâmetros
def wasMonitor(serverName, cellName, nodeName, module):
    # set up globals
    global AdminConfig
    global AdminControl
    
    defaultFile =  os.path.join(OUTPUT_PATH, DAY_FORMAT.format(Date()) + "_metricLog_" + module + ".csv")
    
    # Informações de perfil
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
        #parametros de configuração	
        params = [AdminControl.makeObjectName(srvInfo), module, java.lang.Boolean ('true')]
        
        #Assinatura de metodo para receber params	
        sigs = ['javax.management.ObjectName','java.lang.String','java.lang.Boolean']
        
        #server metrics type module
        metrics = AdminControl.invoke_jmx (perfOName, 'getStatsString', params, sigs)
        
        if(String(module).equals("threadPoolModule") or String(module).equals("beanModule") or String(module).equals("connectionPoolModule") or String(module).equals("hamanagerModule") or String(module).equals("objectPoolModule") or String(module).equals("servletSessionsModule") or String(module).equals("jvmRuntimeModule")):
            genericModuleParser(defaultFile, metrics, module)

        else:
            print "Module '" + module + "' não encontrado!!! Por favor, verifique se este module esta disponivel neste servidor"
            print "Dica: no final deste script voce encontrara um exemplo de como verificar se este module existe."
        
    except Error,e:
        processLogErrors(ERROR_FILE, "Erro ao obter objetos do WebSphere para obtencao das coletas de metricas")
        print "Erro ao obter objetos do WebSphere para obtencao das coletas de metricas"

        
# Método que tem por objetivo realizar testes de modules específicos e imprimir a saida na tela
def genericModuleParserTest(defaultFile, metrics, module):
    splitDescriptor = metrics.split('Descriptor')
    for el in splitDescriptor:
        splitMetrics = el.split('} {')
        for el2 in splitMetrics:			
            lineParsed = String(String(el2).replace(String("{"),String(""))).replace(String("}"),String(""))
            print "[WASMONITOR] " + lineParsed

# Método que tem por objetivo realizar o parser das informações retornadas pelo websphere
def genericModuleParser(defaultFile, metrics, module):
    splitDescriptor = metrics.split('Descriptor')
    for el in splitDescriptor:
        splitMetrics = el.split('} {')
        
        if(len(splitMetrics) > 8):
            node       = String(String(splitMetrics[0]).replace(String("{"),String(""))).replace(String("Node "),String(""))
            srv        = String(splitMetrics[1]).replace(String("Server "),String(""))
            metricName = String(splitMetrics[3]).replace(String("Name"),String(""))
            type       = String(String(splitMetrics[5]).replace(String("{"),String(""))).replace(String("PmiDataInfo Name "),String(""))
            desc       = String(String(String(splitMetrics[7]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Description "),String(""))
            #Comment is not needed
            #comm      = String(String(String(splitMetrics[9]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Comment "),String(""))
            time       = String(splitMetrics[14]).replace(String("Time "),String(""))

            outMetrics = srv + "\";\""
            outMetrics = outMetrics + node + "\";\""
            outMetrics = outMetrics + metricName + "\";\""
            outMetrics = outMetrics + type + "\";\""
            outMetrics = outMetrics + desc + "\";\""
            #Comment is not needed
            #outMetrics = outMetrics + comm + "\";\""
            outMetrics = outMetrics + time + "\";\""
	           
            if(len(splitMetrics) > 15):
                if(String(splitMetrics[15]).contains(String("Count "))):
                    total          = ""
                    count          = String(String(String(splitMetrics[15]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Value Count "),String(""))
                    mean           = ""
                    current        = ""
                    lowWaterMark   = ""
                    highWaterMark  = ""
                elif(String(splitMetrics[15]).contains(String("Total "))):
                    total          = String(String(String(splitMetrics[15]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Value Total "),String(""))
                    count          = String(String(String(splitMetrics[16]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Count "),String(""))
                    mean           = String(String(String(splitMetrics[17]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Mean "),String(""))
                    current        = ""
                    lowWaterMark   = ""
                    highWaterMark  = ""
                elif(String(splitMetrics[15]).contains(String("Current "))):
                    total          = ""
                    count          = ""
                    mean           = ""
                    current        = String(String(String(splitMetrics[15]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Value Current "),String(""))
                    lowWaterMark   = String(String(String(splitMetrics[16]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("LowWaterMark "),String(""))
                    highWaterMark  = String(String(String(splitMetrics[17]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("HighWaterMark "),String(""))
                elif(String(splitMetrics[15]).contains(String("ExternalWrite"))):
                    total          = ""
                    count          = ""
                    mean           = ""
                    current        = String(String(String(splitMetrics[15]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Value Current "),String(""))
                    lowWaterMark   = String(String(String(splitMetrics[16]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("LowWaterMark "),String(""))
                    highWaterMark  = String(String(String(splitMetrics[17]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("HighWaterMark "),String(""))
                elif(String(splitMetrics[15]).contains(String("ExternalRead"))):
                    total          = ""
                    count          = ""
                    mean           = ""
                    current        = String(String(String(splitMetrics[15]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("Value Current "),String(""))
                    lowWaterMark   = String(String(String(splitMetrics[16]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("LowWaterMark "),String(""))
                    highWaterMark  = String(String(String(splitMetrics[17]).replace(String("{"),String(""))).replace(String("}"),String(""))).replace(String("HighWaterMark "),String(""))
                else:
                    processLogErrors(ERROR_FILE, "### Unexpected line to be parsed ###\n")
                    processLogErrors(ERROR_FILE, "Selected info\n")
                    processLogErrors(ERROR_FILE, el + "\n")
                    processLogErrors(ERROR_FILE, "Broken info\n")
                    processLogErrors(ERROR_FILE, "\n".join(splitMetrics) + "\n")
                    total          = "erro"
                    count          = "erro"
                    mean           = "erro"
                    current        = "erro"
                    lowWaterMark   = "erro"
                    highWaterMark  = "erro"

                outMetrics = outMetrics + total          + "\";\""
                outMetrics = outMetrics + count          + "\";\""
                outMetrics = outMetrics + mean           + "\";\""
                outMetrics = outMetrics + current        + "\";\""
                outMetrics = outMetrics + lowWaterMark   + "\";\""
                outMetrics = outMetrics + highWaterMark 
                processLogMetrics(defaultFile, outMetrics, module)
		   
            else:
                processLogErrors(ERROR_FILE, "Line ignored:\n")
                processLogErrors(ERROR_FILE, ",".join(splitMetrics) + "\n" )

# Recebe path de arquivo de log para registrar falhas nas coletas e eventuais exceções
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
        pass	
	
# recebe o path e objetos (AdminControl) a serem processados e escreve no respectivo arquivo
def processLogMetrics(fullFileName, metrics, module):
    try:
        #Contatena hora de processamento
        now = Date()
        outInfo = "\"" + DAY_FORMAT.format(now) + " " + HOUR_FORMAT.format(now) + "\";\"" + metrics + "\";\n"

        # verifica se o arquivo existe e abre em modo write ou append
        if (os.path.isfile(fullFileName)):
            outfile = open(fullFileName,'a') # Abre o arquivo em modo append
            outfile.write(outInfo)
            
        else:
            if( String(module).equals("threadPoolModule") or String(module).equals("beanModule") or String(module).equals("connectionPoolModule") or String(module).equals("hamanagerModule") or String(module).equals("objectPoolModule") or String(module).equals("servletSessionsModule") or String(module).equals("jvmRuntimeModule") ):
                # Abre o arquivo em modo write
                outfile = open(fullFileName,'w')
            
                header = "Date;"
                header = header + "Server;"
                header = header + "Node;"
                header = header + "Metric;"
                header = header + "Type;"
                header = header + "Description;"
                # Comment not needed
                #header = header + "Comment;"
                header = header + "Time;"
            
                header = header + "Total;"
                header = header + "Count;"
                header = header + "Mean;"
                header = header + "Current;"
                header = header + "LowWaterMark;"
                header = header + "HighWaterMark;"
            
                # Finaliza e escreve o cabecalho
                header = header + "\n"
                outfile.write(header)
            
            else:
                processLogErrors(ERROR_FILE, "O module '" + module + "' nao existe.")
            
        outfile.close() # fecha o arquivo

    except Error,e:
        processLogErrors(ERROR_FILE, e)
        pass

        
# Método para obtencao da lista de servidores e nodes e para o processamento das métricas para cada servidor
def processServerMetrics(module):
    #--------------------------------------------------------------
    # set up globals
    #--------------------------------------------------------------
    global AdminConfig
    global AdminControl
		
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
        
        #verifica se as informações foram encontradas pelo regex
        if(matcherServerInfor.find()):
            serverName =  matcherServerInfor.group(2) # Server Name
            cellName   =  matcherServerInfor.group(3) # Cell Name
            nodeName   =  matcherServerInfor.group(4) # Node Name
			
            # Para não coletar métricas do httpServer
            if(not String(serverName).contains(String("webserver")) and not String(serverName).contains(String("http"))  and not String(serverName).contains(String("dmgr"))):
                try:
                    wasMonitor(serverName, cellName, nodeName, module)
                    
                except Error, e:
                    processLogErrors(ERROR_FILE, "Erro no processamento de metricas do servidor: "+serverName)
                    processLogErrors(ERROR_FILE, e)	
                    pass	

#-----------------------------------------------------------------
# Main
#
#   Obtém lista de tipos de métricas ex: connectionPoolModule, hamanagerModule, objectPoolModule, servletSessionsModule, threadPoolModule
#   srvInfo = AdminControl.completeObjectName ("type=Server,name=server1,node=win-websphereNode01,*")
#	perfName = AdminControl.completeObjectName ('process=server1,node=win-websphereNode01,type=Perf,*')
#	perfOName = AdminControl.makeObjectName (perfName)
#	params = [AdminControl.makeObjectName (srvInfo)]
#	sigs = ['javax.management.ObjectName']
#	AdminControl.invoke_jmx (perfOName, 'listStatMemberNames', params, sigs)
#    
#    Obtém level de instrumentação( lista de modules ) 
#	AdminControl.invoke (perfName, 'getInstrumentationLevelString')
#	EX: 'ExtensionRegistryStats.name=
#		F:SipContainerModule=
#		F:beanModule=
#		F:cacheModule=
#		F:connectionPoolModule=
#		F:hamanagerModule=
#		F:jvmRuntimeModule=
#		F:objectPoolModule=
#		F:orbPerfModule=
#		F:servletSessionsModule=
#		F:systemModule=
#		F:threadPoolModule=
#		F:transactionModule=
#		F:webAppModule=F'
#-----------------------------------------------------------------

if (len(sys.argv) == 2):
    # Diretorio para escrita das metricas coletadas
    global OUTPUT_PATH
    global ERROR_FILE

    modules = sys.argv[0]
    OUTPUT_PATH = sys.argv[1]
    
    ERROR_FILE  =  os.path.join(OUTPUT_PATH, DAY_FORMAT.format(Date()) + "_errorLog.log")
        
    splitModules = modules.split(',')
    for aModule in splitModules:
        # Remove eventuais espacos em branco existentes
        aModule = String(aModule).replace(String(" "),String(""))
        processServerMetrics(aModule)
    
else:
    print "Este script requer dois parametros para sua execucao:"
    print "1 - Lista de modulos para os quais serao extraidas as metricas."
    print "Segue a lista de modules disponiveis:"
    print "   - beanModule" 
    print "   - connectionPoolModule"
    print "   - hamanagerModule"
    print "   - objectPoolModule "
    print "   - servletSessionsModule"
    print "   - threadPoolModule"
    print "   - jvmRuntimeModule"
    print "   - transactionModule"
    print "   - webAppModule"
    print "   - cacheModule"
    print "   - orbPerfModule"
    print "   - SipContainerModule"
    print "   - systemModule"
    print "Caso dois ou mais modulos precisem ser consultados, os seus nomes devem ser fornecidos separados por virgula"
    print "2 - Diretorio (sem \\ ou / no final) para gravacao dos arquivos de saida"
    print "Exemplo:  \"beanModule,servletSessionsModule\" \"C:\Windows\Temp\""