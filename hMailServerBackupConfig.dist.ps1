<#

.SYNOPSIS
	hMailServer Backup

.DESCRIPTION
	Configuration for hMailServer Backup

.FUNCTIONALITY
	Backs up hMailServer, compresses backup and uploads to NAS and LetsUpload.io

.PARAMETER 

	
.NOTES
	Run at 11:58PM from task scheduler in order to properly cycle log files.
	
.EXAMPLE


#>

<###   USER VARIABLES   ###>
$VerboseConsole        = $True                  # If true, will output debug to console
$VerboseFile           = $True                  # If true, will output debug to file

<###   DATA DIR BACKUP   ###>
$BackupDataDir         = $True                  # If true, will backup data dir via robocopy

<###   MISCELLANEOUS BACKUP FILES   ###>        # Array of additional miscellaneous files to backup - Use full path
$BackupMisc            = $True                  # True will backup misc files listed below
$MBUFOLDER				= "MISC_FILES"		
$MiscBackupFiles       = @(
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v310.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v312.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v320.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v330.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v340.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v341.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v342.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v343.pre" 
"C:\Program Files\JAM Software\SpamAssassin for Windows\etc\spamassassin\v400.pre" 
)

<###   FOLDER LOCATIONS   ###>

$hMSDir                = "C:\Progra~2\hMailServer"       					# hMailServer Install Directory
$SADir                 = "C:\Progra~1\JAM Software\SpamAssassin for Windows"  			# SpamAssassin Install Directory
$SAConfDir             = "C:\Progra~1\JAM Software\SpamAssassin for Windows\etc\spamassassin"  	# SpamAssassin Conf Directory
$MailDataDir           = "C:\Progra~2\hMailServer\Data"          				# hMailServer Data Dir
$BackupTempDir         = "D:\HMS-Backup-TEMP"   						# Temporary backup folder for RoboCopy to compare
$BackupLocation        = "D:\HMS-BACKUP"        						# Location archive files will be stored
$MySQLBINdir           = "C:\Progra~1\MySQL\MySQL Server 8.0\bin"   				# MySQL BIN folder location
$LogBackupLocation 	   = "D:\HMS-Log-Archive"						# Log File Backup Location

<###   HMAILSERVER COM VARIABLES   ###>
$hMSAdminPass          = "SuperSecret"  # hMailServer Admin password

<###   SPAMASSASSIN VARIABLES   ###>
$UseSA                 = $True                  # Specifies whether SpamAssassin is in use
$UseCustomRuleSets     = $False                 # Specifies whether to download and update KAM.cf  <<---- ALREADY USING OFFICIAL KAM UPDATE CHANNEL
$SACustomRules         = @(                     # URLs of custom rulesets
	"https://www.pccc.com/downloads/SpamAssassin/contrib/KAM.cf"
	"https://www.pccc.com/downloads/SpamAssassin/contrib/nonKAMrules.cf"
)

<###   OPENPHISH VARIABLES   ###>               # https://hmailserver.com/forum/viewtopic.php?t=40295
$UseOpenPhish          = $False                 # Specifies whether to update OpenPhish databases - for use with Phishing plugin for SA - requires wget in the system path
$PhishFiles            = @{
	"https://data.phishtank.com/data/online-valid.csv" = "$SAConfDir\phishtank_Live-feed.csv"
	"https://openphish.com/feed.txt" = "$SAConfDir\openphish-feed.txt"
	"https://phishstats.info/phish_score.csv" = "$SAConfDir\phishstats-feed.csv" 
}

<###   NAS COM VARIABLES  ###>
$NASBackup		= $True                  		# Enable or disable NAS Backup
$NasHost		= "NAS IP or HOST"			# Nas Backup Location
$NASBackupLocation	= "\\NAS\HMS_Backup"
$NasAdmin          	= "admin"  				# Nas admin User
$NasAdminpass      	= "SuperSecret"  			# Nas admin User Password
$NasSshKey		= "ssh key goes here"			# SshHostKeyFingerprint

<###   WINDOWS SERVICE VARIABLES   ###>
$hMSServiceName        = "hMailServer"          # Name of hMailServer Service (check windows services to verify exact spelling)
$SAServiceName         = "spamassassin"         # Name of SpamAssassin Service (check windows services to verify exact spelling)
$ServiceTimeout        = 5                      # number of minutes to continue trying if service start or stop commands become unresponsive

<###   PRUNE BACKUPS VARIABLES   ###>
$PruneBackups          = $True                  # If true, will delete local backups older than N days
$DaysToKeepBackups     = 3                      # Number of days to keep backups - older backups will be deleted

<###   PRUNE MESSAGES VARIABLES   ###>
$DoDelete              = $True                  # FOR TESTING - set to FALSE to run and report results without deleting messages and folders
$PruneMessages         = $True                  # True will run message pruning routine
$PruneSubFolders       = $True                  # True will prune messages in folders levels below name matching folders
$PruneEmptySubFolders  = $True                  # True will delete empty subfolders below the matching level unless a subfolder within contains messages
$DaysBeforeDelete      = 15                     # Number of days to keep messages in pruned folders
$SkipAccountPruning    = "user@dom.com|a@b.com" # User accounts to skip - uses regex (disable with "" or $NULL)
$SkipDomainPruning     = "domain.tld|dom2.com"  # Domains to skip - uses regex (disable with "" or $NULL)
$PruneFolders          = "Trash|Deleted|Deleted Items|Junk E-mail|Spam|Folder-[0-9]{6}|Unsubscribes"  # Names of IMAP folders you want to cleanup - uses regex

<###   FEED BAYES VARIABLES   ###>
$FeedBayes             = $True                  				# True will run Bayes feeding routine
$DoSpamC               = $True                  				# FOR TESTING - set to FALSE to run and report results without feeding SpamC with spam/ham
$BayesSubFolders       = $True                  				# True will feed messages from subfolders within regex name matching folders
$BayesDays             = 7                      				# Number of days worth of spam/ham to feed to bayes
$HamFolders            = "Inbox|Ham"            				# Ham folders to feed messages to spamC for bayes database - uses regex
$SpamFolders           = "Spam|Junk E-mail"            				# Spam folders to feed messages to spamC for bayes database - uses regex
$SkipAccountBayes      = "mirror@mydomain.com|spambox@mydomain.com" 		# User accounts to skip - uses regex - If not used, leave blank (not "") or it will match EVERYTHING! "mirror@mydomain.com|a@b.com" 
$SkipDomainBayes       =							# Domains to skip - uses regex - IF NOT USED, LEAVE BLANK (NOT "") or it will match EVERYTHING! "domain.tld|dom2.com"
$SyncBayesJournal      = $True                  				# True will sync bayes_journal after feeding messages to SpamC
$BackupBayesDatabase   = $True                  				# True will backup the bayes database to bayes_backup - NOT insert the file in the backup/upload routine
$UseSAMySQL            = $True                  				# Specifies whether database used is MySQL or Text Database
$SASQLDatabase         = "spamassassin"						# spamassassin MySQL database name
$BayesBackupLocation   = "D:\bayes_backup\bayes_backup.db"      		# Bayes backup FILE, Enter complete path with file name of the backup file.

<###   MySQL VARIABLES   ###>
$BackupDB	       = $True			# Specifies whether to run BackupDatabases function (options below)(FALSE will skip)
$UseMySQL              = $True                  # Specifies whether database used is MySQL
$BackupAllMySQLDatbase = $False                 # True will backup all databases, not just hmailserver - must use ROOT user for this
$MySQLDatabase         = "hmail"          	# MySQL database name
$MySQLUser             = "root"                 # hMailServer database user
$MySQLPass             = "SuperSecret"  	# hMailServer database password
$MySQLPort             = 3306                   # MySQL port

<###   7-ZIP VARIABLES   ###>
$UseSevenZip           = $True                  # True will compress backup files into archive
$PWProtectedArchive    = $True                  # False = no-password zip archive, True = AES-256 encrypted multi-volume 7z archive
$VolumeSize            = "180m"                 # Size of archive volume parts - maximum 200m recommended - valid suffixes for size units are (b|k|m|g)
$ArchivePassword       = "onemoresecret"  	# Password to 7z archive

<###   LETSUPLOAD API VARIABLES   ###>
$UseLetsUpload         = $False                 # True will run upload routine
$APIKey1               = "SuperSecret"  	# Get key from letsupload.io
$APIKey2               = "SuperSecret"  	# Get key from letsupload.io
$IsPublic              = 0                      # 0 = Private, 1 = Unlisted, 2 = Public in site search
$MaxUploadTries        = 5                      # Maximum number of upload tries before giving up

<###   HMAILSERVER LOG VARIABLES   ###>
$PruneLogs             = $True                 # If true, will delete logs in hMailServer \Logs folder older than N days
$ArchiveLogs	       = $True			# If true, will Archive logs in Log Archive Folder	
$DaysToKeepLogs        = 7                     # Number of days to keep old hMailServer Logs

<###   CYCLE LOGS VARIABLES   ###>             # Array of logs to cycle - Full file path required - not limited to hmailserver log dir
$CycleLogs             = $True                 # True will cycle logs (rename with today's date)
$LogsToCycle           = @(
	"C:\Program Files (x86)\hMailServer\Logs\hmailserver_events.log"
	"C:\Program Files (x86)\hMailServer\Logs\SpamD.log"
)

<###   EMAIL VARIABLES   ###>
$EmailFrom             =  "HMS BACKUP SYSTEM <me@mydomain.com>"
$EmailTo               = "mygmail@gmail.com"
$Subject               = "hMailServer Nightly Backup"
$SMTPServer            = "127.0.0.1"
$SMTPAuthUser          = "me@mydomain.com"
$SMTPAuthPass          = "SuperSecret"
$SMTPPort              =  25
$SSL                   = $False                 # If true, will use tls connection to send email
$UseHTML               = $True                  # If true, will format and send email body as html (with color!)
$AttachDebugLog        = $True                  # If true, will attach debug log to email report - must also select $VerboseFile
$MaxAttachmentSize     = 1                      # Size in MB

<###   GMAIL VARIABLES   ###>
<#  Alternate messaging in case of hMailServer failure  #>
<#  "Less Secure Apps" must be enabled in gmail account settings  #>
$GmailUser             = "backupgmail@gmail.com"
$GmailPass             = "SuperSecret"
$GmailTo               = "mygmail@gmail.com"
