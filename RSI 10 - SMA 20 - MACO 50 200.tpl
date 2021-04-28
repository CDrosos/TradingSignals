<chart>
id=132545329908955517
symbol=BTCUSD
period=240
leftpos=2401
digits=2
scale=8
graph=1
fore=1
grid=1
volume=0
scroll=0
shift=1
ohlc=1
one_click=0
one_click_btn=1
askline=0
days=1
descriptions=0
shift_size=20
fixed_pos=0
window_left=26
window_top=26
window_right=1466
window_bottom=551
window_type=3
background_color=0
foreground_color=16777215
barup_color=65280
bardown_color=65280
bullcandle_color=0
bearcandle_color=16777215
chartline_color=65280
volumes_color=3329330
grid_color=10061943
askline_color=255
stops_color=255

<window>
height=148
fixed_height=0
<indicator>
name=main
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=MA crosses arrows or lines mtf+alerts
flags=851
window_num=0
<inputs>
TimeFrame=0
TimeFrameCustom=0
FastMaPeriod=50
FastMaMethod=0
FastMaPrice=0
SlowMaPeriod=200
SlowMaMethod=0
SlowMaPrice=0
DisplayType=0
LinesWidth=3
ArrowSize=2
alertsOn=false
alertsOnCurrent=true
alertsMessage=true
alertsSound=false
alertsPushNotif=false
alertsEmail=false
soundFile=alert2.wav
ArrowCodeUp=233
ArrowCodeDn=234
ArrowGapUp=0.5
ArrowGapDn=0.5
ArrowOnFirst=true
Interpolate=true
</inputs>
</expert>
shift_0=0
draw_0=12
color_0=3329330
style_0=0
weight_0=2
shift_1=0
draw_1=12
color_1=255
style_1=0
weight_1=2
shift_2=0
draw_2=0
color_2=3329330
style_2=0
weight_2=3
shift_3=0
draw_3=0
color_3=255
style_3=0
weight_3=3
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=20
shift=0
method=0
apply=0
color=65535
style=0
weight=2
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=50
fixed_height=0
<indicator>
name=Relative Strength Index
period=10
apply=0
color=16748574
style=0
weight=2
min=0.00000000
max=100.00000000
levels_color=12632256
levels_style=0
levels_weight=1
level_0=30.00000000
level_1=70.00000000
period_flags=0
show_data=1
</indicator>
</window>

<expert>
name=InvestAnswerSignals
flags=339
window_num=0
<inputs>
ShowSignalAlerts=true
SendSignalAlertsByEmail=false
SendSignalAlertsByMobileNotifiaction=true
EmailSubject=Alert From InvestAnswersSignals ExpertAdvisor
RSI_MACD=2
RSI_Period=10
RSI_Shift=0
RSI_AppliedPrice=0
MACO_Enable=true
MACO_Name=MA crosses arrows or lines mtf+alerts
MACO_TimeFrame=0
MACO_TimeFrameCustom=0
MACO_FastMaPeriod=50
MACO_FastMaMethod=0
MACO_FastMaPrice=0
MACO_SlowMaPeriod=200
MACO_SlowMaMethod=0
MACO_SlowMaPrice=0
MACD_Fast_EMA_Period=8
MACD_Slow_EMA_Period=21
MACD_Signal_Period=5
MACD_Applied_Price=0
</inputs>
</expert>
</chart>

