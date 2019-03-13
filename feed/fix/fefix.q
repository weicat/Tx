.module.fefix:2018.03.29;

txload "core/febase";
txload "feed/fix/fixbase";

//
guessex:{[x;y]z:first string y;($[z in "256";`XSHG;z in "0134789";`XSHE;y like "IF*";`CCFX;`NONE])^(`SS`SZ`HK`XSHG`XSHE!`XSHG`XSHE`XHKG`XSHG`XSHE)x};
sectype:{[x;y]$[y in `CFFEX`SHFE`DCE`ZCE;$[(x like "IO*")|(x like "m_o*");`OPT;`FUT];y in `XSHG`SS`XEHE`SZ;$[8=count string x;`OPT;`];`]}; /[sym;ex]

/kx order msg
.upd.ordnew:{[x].temp.X2:x;if[x[`sym]<>.conf.me;:.ha.ordnew[x]];k:x`oid;if[not null .db.O[k;`sym];:()];k1:newidl[];h:$[count opt:x`ordopt;strdict opt;()!()];.db.O[k;`feoid`ntime`status`ft`ts`acc`fe`acc1`ref`sym`side`posefct`tif`typ`qty`price`ordopt]:(k1;.z.P;.enum`PENDING_NEW),x`ft`ts`acc`sym`acc1`ref`osym`side`posefct`tif`typ`qty`price`ordopt;se:fs2se x`osym;se[1]:se[1]^(`XSHE`XSHG`CCFX`XSGE`XDCE`XZCE`XINE!`SZ`SS`CFFEX`CFFEX`CFFEX`CFFEX`CFFEX)se[1];ac:x`acc1;r:();st:sectype[se[0];se[1]];if[0>ifill smfixr[.conf.fix.downstream;r;.fix`NewOrderSingle;(.fix`ClOrdID`SecurityType`HandlInst`TransactTime`Currency`Symbol`SecurityExchange`TimeInForce`Account`CoveredOrUncovered`ExDestination`SecurityID`Side`OrderQty`Price`OrdType`OpenClose`Text`StopPx`CashMargin)!(k1;st;.fix`AUTOMATED_EXECUTION_ORDER_PRIVATE_NO_BROKER_INTERVENTION;utctime[];`CNY;se[0];$[st~`OPT;`;se[1]];x`tif;ac;1;$[se[1]=`XHKG;`XSHG;se[1]=`XHKE;`XSHE;`];`),x[`side`qty`price`typ`posefct`msg],(h`stoppx;h`cashmargin)];.db.O[k;`status`reason`msg]:(.fix`REJECTED;.enum`BROKER_ERROR;"FIXOrderServerOffline");execrpt[k]];}'; 

.upd.ordcxl:{[x]if[x[`sym]<>.conf.me;:.ha.ordcxl[x]];k:x`oid;r:.db.O[k];$[null r`sym;rejectcxl[x`src;k;x`cid;.enum`UNKNOWN_ORDER_CXL;"UNKNOWN_ORDER"];.db.O[k;`end];rejectcxl[x`src;k;x`cid;.enum`TOO_LATE_TO_CANCEL;"Fill"];[cfeoid:newidl[];.db.O[k;`cfeoid`cid`cstatus`ctime]:(cfeoid;x`cid;.enum`PENDING_CANCEL;now[]);ac:.db.O[k;`acc1];r:();se:fs2se .db.O[k;`sym];se[1]:se[1]^(`XSHE`XSHG`CCFX`XSGE`XDCE`XZCE`XINE!`SZ`SS`CFFEX`CFFEX`CFFEX`CFFEX`CFFEX)se[1];st:sectype[se[0];se[1]];if[0>ifill smfixr[.conf.fix.downstream;r;.fix`OrderCancelRequest;(.fix`OrigClOrdID`ClOrdID`Side`OrderQty`Symbol`SecurityExchange`SecurityType`Account`TransactTime`SecondaryClOrderID)!.db.O[k;`feoid`cfeoid`side`qty],se,(st;ac;utctime[];`)];.db.O[k;`status`qtime]:(.enum`NULL;now[]);rejectcxl[x`src;k;x`cid;.enum`BROKER_ERROR_CXL;"FIXOrderServerOffline"]]]];}'; 

.upd.ordqry:{[x]He:x`who;z:x`id;k:x`orderid;if[null k;k:exec first id from O where clt=He,cltid=z];$[not null O[k;`fsym];[ac:O[k;`cltacc];r:();if[SysOpt`USEACCMAP;am:accmap[ac;O[k;`ex];SysOpt`DSPEERID];ac:am[0];if[not null dt:am[1];r:enlist (enlist .fix`DeliverToCompID)!enlist dt]];smfixr[SysOpt`DSPEERID;r;.fix`OrderStatusRequest;(.fix`ClOrdID`Symbol`SecurityExchange`Side`SecondaryClOrderID`Account)!k,O[k;`sym`ex`side`cltid2],ac]];smkx[He;`ExecRpt;`id`status`reason`text!(z;.enum`REJECTED;.enum`UNKNOWN_ORDER;`OrderServerNotHaveThisOrder)]];}'; 

fillhs:{[k;y]if[0=count y[.fix`CumQty];y[.fix`CumQty]:0f^O.db.[k;`cumqty]];if[(0=count y[.fix`AvgPx])|((y[.fix`OrdStatus]~.fix`CANCELED)&(y[.fix`AvgPx]~0f)&(y[.fix`CumQty]<=.db.O[k;`cumqty]));y[.fix`AvgPx]:0f^.db.O[k;`avgpx]];if[0=count y[.fix`LastShares];y[.fix`LastShares]:0f];if[0=count y[.fix`LastPx];y[.fix`LastPx]:0f];y}; /�����ɽ��ر�δ�͵�FIX�����ֶ��Զ���ȫ,�����ɽ��ر�״̬ΪCANCELEDʱavgpx����Ϊ��,�����³ɽ�ʱ����֮(20110426,20110701)

patchcxlhs:{[x;y]if[(.db.O[x;`status]=.fix`CANCELED)&(0<O[x;`cumqty])&(0=.db.O[x;`avgpx])&(.db.O[x;`cumqty]=y[.fix`CumQty]);.db.O[x;`avgpx`lastqty`lastpx]:y[.fix`AvgPx`LastShares`LastPx];execrpt[x]];}; /�����ں���Ĳ��ֳɽ��ر������ɽ�����(20110701)

/fix msg
.fix.FIX[`8]:{[x;y]u:`$y[.fix`ClOrdID];v:`$y[.fix`OrigClOrdID];k:exec first id from .db.O where feoid=u^v;oid:`$y[.fix`OrderID];tt:y[.fix`ExecTransType];if[null .db.O[k;`sym];:()];s:y[.fix`OrdStatus];y:fillhs[k;y];if[(.db.O[k;`status] in .fix`REJECTED`FILLED`DONE_FOR_DAY`CANCELED`REPLACED)&(not tt~.fix`STATUS);patchcxlhs[k;y];:()];if[(.db.O[k;`qty]=y[.fix`CumQty])&(s<>.fix`FILLED);s:.fix`FILLED];if[s=.fix`PENDING_CANCEL;.db.O[k;`cstatus]:s;s:.db.O[k;`status];if[(0<y[.fix`CumQty])&s in .fix`PENDING_NEW`NEW;s:.fix`PARTIALLY_FILLED]];if[(.db.O[k;`cstatus]=.fix`PENDING_CANCEL)&(s in .fix`PENDING_NEW`NEW`PARTIALLY_FILLED)&(tt~.fix`STATUS);.db.O[k;`cstatus]:.enum`NULL];.db.O[k;`rtime`status`cumqty`avgpx`lastqty`lastpx]:(now[];s),y[.fix`CumQty`AvgPx`LastShares`LastPx];if[0f<.db.O[k;`lastqty];.db.O[k;`ftime]:now[]];if[(s=.fix`CANCELED)&(.db.O[k;`cstatus]<>.fix`CANCELED);.db.O[k;`cstatus]:.fix`CANCELED;if[null .db.O[k;`ctime];.db.O[k;`ctime]:now[]]];$[not null v;$[null .db.O[k;`cordid];.db.O[k;`cordid]:oid;.db.O[k;`origid]:oid];null .db.O[k;`ordid];.db.O[k;`ordid]:oid;.db.O[k;`origid]:oid];if[.db.O[k;`status]=.fix`REJECTED;.db.O[k;`reason`msg]:({$[0=count x;0N;x]} y[.fix`OrdRejReason];y[.fix`Text])];if[count y[.fix`Text];.db.O[k;`msg]:y[.fix`Text]];execrpt[k];}; /ExecutionReport,fill NOE canceltime(20110519),�������ɲ��������Ȼس�����ɻر�,����Ϊ0,��ز��ֳɽ��ر�,������Ч,����������(20110701)

.fix.FIX[`9]:{[x;y];k:exec first id from .db.O where feoid=`$y[.fix`OrigClOrdID];if[null .db.O[k;`sym];:()];.db.O[(k;`cstatus`cordid`reason`msg`rtime);(.enum`REJECTED;`$y[.fix`OrderID];{$[0=count x;0N;x]} y[.fix`CxlRejReason];y[.fix`Text];now[])];rejectcxl[.db.O[k;`ft];.k;.db.O[k;`cid];.db.O[k;`reason];.db.O[k;`msg]];}; /OrderCancelReject