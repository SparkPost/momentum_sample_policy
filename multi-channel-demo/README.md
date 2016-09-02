# Multi-Channel Demo

This project demonstrates the following use-cases

* Templates
	* Send email via REST Transmission API
* Transmissions
	* Send SMS via REST Transmission API
	* Send HTTP via REST Transmission API
	* Forward messages to API endpoint
* Suppression
	* Suppress email to address(s) on blacklist
	* Suppress email during quiet time
	* Suppress email during customer specific quiet hours
* Contact Preferences
	* Route email based on user specified time-window
* Inbound to HTTP
	* route inbound email to HTTP endpoint
		* SMTP
		* SMPP

		
## Usage

### Momentum Policy

1. Copy conf.d and lua directory to `/opt/msys/ecelerity/etc/conf/default`
2. Add `include "conf.d"` to the end of `ecelerity.conf`
3. Configure SMPP to aggregator
4. Create preferences DB See [Create Preferences Scheme](#Create+Preferences+Scheme) below


#### Create Preferences Scheme

* `sqlite3 /opt/msys/ecelerity/etc/conf/default/preferences.sqlite`

```
BEGIN TRANSACTION;
CREATE TABLE BLACKLIST(
   ID INT PRIMARY KEY     NOT NULL,
   ADDRESS        TEXT    NOT NULL,
   BULK           INT     NOT NULL
);
INSERT INTO "BLACKLIST" VALUES(1,'blockme@sparkpost.com',1);
INSERT INTO "BLACKLIST" VALUES(2,'blockme2@sparkpost.com',1);
INSERT INTO "BLACKLIST" VALUES(3,'blockme3@sparkpost.com',1);

CREATE TABLE USER_PREF (
   ID                  INT PRIMARY KEY    NOT NULL,
   QUIET_START         INT    NOT NULL,
   QUIET_END           INT    NOT NULL,
   NOTE                TEXT   NOT NULL
);
INSERT INTO "USER_PREF" VALUES(1,0,86400,'Quiet all day');
INSERT INTO "USER_PREF" VALUES(2,0,0,'Never quiet');
INSERT INTO "USER_PREF" VALUES(3,0,43200,'Quiet first half of day');
INSERT INTO "USER_PREF" VALUES(4,43200,86400,'Quiet second half of day');

CREATE TABLE USER_ALT_ADDRESS (
   ID                  INT PRIMARY KEY    NOT NULL,
   USERID              INT    NOT NULL,
   ADDRESS             TEXT   NOT NULL,
   START               INT    NOT NULL,
   END                 INT    NOT NULL,
   NOTE                TEXT   NOT NULL
);
INSERT INTO "USER_ALT_ADDRESS" VALUES(1,100,'YOUR_TELEPHONE_NUMBER@uso.sms.int',0,86400,'SMS All Day');
INSERT INTO "USER_ALT_ADDRESS" VALUES(2,101,'YOUR_TELEPHONE_NUMBER@uso.sms.int',0,43200,'First half day');
INSERT INTO "USER_ALT_ADDRESS" VALUES(3,102,'YOUR_TELEPHONE_NUMBER@uso.sms.int',43200,86400,'Second half day');

```



### Web Client
