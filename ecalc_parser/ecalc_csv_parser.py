
import sys

STALL  = 0
CRUISE = 1
PITCH  = 2

if len(sys.argv) != 2:
    raise Exception("Only input one argument.")

fname = sys.argv[1]
print("Opening file [" + fname + "]")

with open(sys.argv[1]) as f:
    lines = f.readlines()

project_name    = 'project name missing'
motor_v_inf     = [0]*3
motor_T         = [0]*3
motor_e_prop    = [0]*3
motor_e_motor   =  0

e_power = 0

for line in lines:
    if(len(line) < 5):
        continue
        #if a line has les than 5 characters, it doesn't have any useful data
    
    splitLine = line.split(';')
    firstWord = splitLine[0]
    

    if(firstWord == 'Project Name'):
        project_name = splitLine[2]
    if(firstWord == 'avail.Thrust @ Flight Speed:'):
        temp = splitLine[2].split()[0]
        if(temp == "-"):
            motor_T[CRUISE] = 0
        else:
            motor_T[CRUISE] = float(temp) / 1000 #from g-->kg
        motor_v_inf[CRUISE] = float(splitLine[2].split()[2]) * (1000.0/3600) #km/hr --> m/s
    if(firstWord == 'Pitch Speed:'):
        motor_v_inf[PITCH] = float(splitLine[2]) * (1000.0/3600) #km/hr-->m/s
    if(firstWord == 'Static Thrust:'):
        motor_T[STALL] = float(splitLine[2]) / 1000 #g-->kg
    if(firstWord == 'specific Thrust:'):
        motor_e_prop[CRUISE] = float(splitLine[2])/1000 #g --> kg
    if(firstWord == 'Efficiency:'):
        motor_e_motor = float(splitLine[2]) / 100 #from % --> decimal
    if(firstWord == 'electric Power:'):
        e_power = float(splitLine[2])
motor_e_prop[STALL] = motor_T[STALL] / e_power

print("\nProject name = [" + project_name + "]")
print("\tmotor_v_inf   :  " + str(motor_v_inf))
print("\tmotor_T       :  " + str(motor_T))
print("\tmotor_e_prop  :  " + str(motor_e_prop))
print("\tmotor_e_motor :  " + str(motor_e_motor))

