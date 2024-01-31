import pynusmv
import sys
import re


###################################################################
####################  little helpful methods ######################
###################################################################


## Logical operators ##
NOT = "~"
AND = "/\\"
OR = "\\/"
IMPLIES = " -> "
IFF = "<->"
SUCCESSOR = "'"


#################
#  remove stuff #
#################

## TBD: can we have the name includes dot in genQBF? ##
def remove_dot(s):
	s = s.replace(".", "-")
	return s
########################################################

############################
#  Check type of variables #
############################

## value is boolean ##
def isBoolean(key):
	return ((key == 'TRUE') or (key == 'FALSE'))

## if values is digits ##
def isNumber(key):
	return key.isdigit()

###################################
#  Initial State Construction #
###################################

## assign a boolean value to a variable key ##
def assignBool(key, dict):
	var_name = remove_dot(key)
	if (dict[key] == 'TRUE'):
		return var_name
	else:
		return NOT+var_name

## assign a digit value to a variable key ##
def assignBin(key, dict):
	bits = []
	var_name = remove_dot(key)

	num_bits = bitblasting_dict[key]
	binary = format(int(dict[key]), '0'+str(num_bits)+'b').replace("0b", "")
	counter = num_bits-1
	for b in binary:
		if (b == '1'):
			bits.append(var_name+"_"+str(counter))
		else:
			bits.append(NOT+var_name+"_"+str(counter))
		counter-=1
	return conjunct(bits)

## assign a bool variable value to a variable key ##
def assignVal(key, dict):
	var_name = remove_dot(key)
	return var_name+IFF+dict[key]


#####################################
#  Transition Relation Construction #
#####################################


# print out all atomic propositions in dict
## All AP values in the current state ##
def getDictAP(dict):
	all_ap = []
	for ap in dict:
		value = dict[ap]
		if(isBoolean(value)):
			all_ap.append(assignBool(ap, dict))
		elif(isNumber(value)):
			all_ap.append(assignBin(ap, dict))
		else:
			name = remove_dot(ap)
			all_ap.append(name+IFF+dict[ap])
	return conjunct(all_ap)

## All AP values in the post state ##
def getNextDictAP(dict):
	all_ap = []
	for ap in dict:
		value = dict[ap]
		if(isBoolean(value)):
			all_ap.append(assignNextBool(ap, dict))
		elif(isNumber(value)):
			all_ap.append(assignNextBin(ap, dict))
		else:
			all_ap.append(assignNextVal(ap, dict))
	return conjunct(all_ap)

## All AP values in the post state ##
def assignNextBin(key, dict):
	bits = []
	name = remove_dot(key)
	num_bits = bitblasting_dict[key]
	binary = format(int(dict[key]),'0'+str(num_bits)+'b').replace("0b", "")
	counter = num_bits-1
	for b in binary:
		if (b == '1'):
			bits.append(name+"_"+str(counter)+SUCCESSOR)
		else:
			bits.append(NOT+name+"_"+str(counter)+SUCCESSOR)
		counter-=1
	return conjunct(bits)

def assignNextBool(key, dict):
	var_name = remove_dot(key)
	if (dict[key] == 'TRUE'):
		return var_name+SUCCESSOR
	else:
		return NOT+var_name+SUCCESSOR

def assignNextVal(key, dict):
	var_name = remove_dot(key)
	return var_name+SUCCESSOR+IFF+dict[key]+SUCCESSOR


####################################
#  Logical Expression Construction #
####################################


## conjunct of all element in a list ##
def conjunct(list):
	if(len(list) == 1):
		return list[0]
	output = ""
	for i in range(len(list)-1):
		output += list[i] + AND
	return "(" + output + list[len(list)-1] + ")"

## disjunct of all element in a list ##
def disjunct(list):
	if(len(list) == 1):
		return list[0]
	output = ""
	for i in range(len(list)-1):
		output += list[i] + OR
	return "(" + output + list[len(list)-1] + ")"

def trans(pre, post):
	return "(("+pre+")"+IMPLIES+"("+post+"))"




###############################
#  HYPERCTL Property Construction #
###############################


### TODO

# binary_eq: two variables matches each bit
def binary_eq(var_l, var_r):
	num_bits = bitblasting_dict[var_l[0]]
	result = []
	for i in range(num_bits):
		left = var_l[0] + "_"+str(i) +"_"+var_l[1]
		right = var_r[0] + "_"+str(i) +"_"+var_r[1]
		# print(left + " <-> " + right)
		result.append(left + IFF + right)
	return conjunct(result)

def binary_assign(var, num):
	num_bits = bitblasting_dict[var[0]]
	if (num > (2**(num_bits))):
		print("[ !!! HyperBMC error: variable ", var[0], " is assigned a value that is out of the bound of its definition in the NuSMV model." )
		quit()
	binary = format(num, '0'+str(num_bits)+'b').replace("0b", "")
	result = []
	counter = num_bits-1
	for b in binary:
		if (b == '1'):
			result.append(var[0] + "_"+str(counter) +"_"+var[1])
		else:
			result.append(NOT+var[0] + "_"+str(counter) +"_"+var[1])
		counter-=1
	return conjunct(result)



#########################
#      Get Arguments    #
#########################
smv_file_name = sys.argv[1]
fomula_file_name = sys.argv[2]
parsed_I_file = sys.argv[3]
parsed_R_file = sys.argv[4]
translated_formula_file_name = sys.argv[5]

FLAG = ""
if(len(sys.argv)==7):
	FLAG = sys.argv[6]

To_Negate_formula=(FLAG=="" or FLAG=="-bughunt")



print("\n============ Read SMV Model ============")
#########################
#  Model Initialization #
#########################

pynusmv.init.init_nusmv()
pynusmv.glob.load_from_file(smv_file_name)
pynusmv.glob.compute_model()
fsm = pynusmv.glob.prop_database().master.bddFsm
enc = fsm.bddEnc

print("\n[ success! SMV model accepted. ]")

# ### DEBUG
# print("====================================")
# print("FSM Model info:")
print("\n============ Parse SMV Model ============")
state_variables = list(enc.stateVars)

print("All variables: ")
print("state variables: ", state_variables)
defined_variables = list(enc.definedVars)
print("defined variables: ", defined_variables)

valid_variables = state_variables + defined_variables
# print(valid_varaibles)

num_states = fsm.count_states(fsm.reachable_states)
print("Total number of reachable states: ", num_states)
# inputs = list(enc.inputsVars)
# print("input variables", inputs)
# atomics = list(enc.definedVars)
# print("atomic propositions", atomics)




############################
#  bit-blasting dictionary #
############################
bitblasting_dict = {}
# build bitblasting_dict
smv_file = open(smv_file_name, 'r')
lines = smv_file.readlines()
for line in lines:
	# print(line)
	if(re.findall("\.\.", line)):
		line = line.split("--", 1)[0].replace("\t","") #remove comments

		if(not line.replace(" ","")):
			pass
		# print(line)
		elif (line): # if it's not empty
			key = re.findall(".*:", line)[0].replace(":","")
			num = re.findall("[\d]*;", line)[0].replace(";","")
			# print(line)
			# print(key)
			# print(num)
			value = int(num).bit_length()

			# bitblasting_dict[key] = value
			for var in state_variables:
				if(key.replace(" ", "") in var):
					bitblasting_dict[var] = value
	# TODO: new data type: unsigned word
	elif(re.findall("unsigned word", line)):
		line = line.split("--", 1)[0].replace("\t","") #remove comments
		# print(line)
		if (line): # if it's not empty
			key = re.split("unsigned", line)[0].replace(":","")
			num_bits = re.split("word", line)[1].replace("[","").replace("]","")
			# print(key)
			# print(num_bits)
			for var in state_variables:
				if(key.replace(" ", "") in var):
					bitblasting_dict[var] = int(num_bits.replace("\n","").replace(";",""))


# print(value)
# print(int(value).bit_length())

print("Dictionary for bit-blasting variables (number of bits needed for each): ")
print(bitblasting_dict)




###################################
#  Initial State Construction #
###################################
initial_state=""
def gen_I():
	initial_state = fsm.pick_one_state(fsm.init)
	init_conditions = []
	dictionary = initial_state.get_str_values()
	for ap in dictionary:
		value = dictionary[ap]
		# print(value)
		if(isBoolean(value)):
			init_conditions.append(assignBool(ap, dictionary))
		elif(isNumber(value)):
			init_conditions.append(assignBin(ap, dictionary))
		# TODO: new data type: unsigned word
		elif("0ud" in value):
			dictionary[ap] = re.split("_", value)[1]
			init_conditions.append(assignBin(ap, dictionary))
		else:
			init_conditions.append(assignVal(ap, dictionary))
		initial_state=conjunct(init_conditions)
		I_bool = open(parsed_I_file, "w")
		I_bool.write(initial_state)
		I_bool.close()

print(initial_state)


#####################################
#  Transition Relation Construction #
#####################################
def gen_R():
	all_transitions = []
	R_bool = open(parsed_R_file, "w")
	for state in fsm.pick_all_states(fsm.reachable_states):
		transitions = []
		curr = state.get_str_values()
		# print('from')
		# print(curr)
		# print('to')
		post_list = [] # list of all next states
		for post_state in fsm.pick_all_states(fsm.post(state)):
			post = post_state.get_str_values()
			# print(post)
			post_list.append(getNextDictAP(post))
		transitions.append(trans(getDictAP(curr), disjunct(post_list)))
		R_bool.write(trans(getDictAP(curr), disjunct(post_list)))
		# R_bool.write(conjunct_trans(transitions))
		R_bool.write(AND + "\n")

	##  write to R_bool file
	# R_bool = open("test_R.bool", "w")
	R_bool.write("TRUE");
	# R_bool.write(conjunct_trans(all_transitions))
	R_bool.close()

	## DEBUG
	# print("\n--------------------")
	# print("transition relations")
	# print("--------------------")
	# print(conjunct_trans(all_transitions))


# generating Boolean model for genQBF
gen_I()
gen_R()
print("\n[ success! SMV model parsed into Boolean Expressions: " + parsed_I_file+"," + parsed_R_file+"]")


##################################
#  HyperCTL* Formula Construction #
##################################
print("\n============ Translate HyperCTL* Formula ============")
text = ""
file = open(fomula_file_name, 'r')
Lines = file.readlines()
for line in Lines:
	if ("#" not in line):
		text += line

print("user input formula: \n"+text)

## detect the optional flag
if (FLAG == "-bughunt"):
	print("(**detect -bughunt flag, formula negated.)\n")
elif  (FLAG == "-find"):
	print("(**detect -find flag, use original formula.)\n")
else:
	print("(**no optional flag detected, perform BMC with negated formula.)\n")


# Define quantifiers here
quantifiers = ["forall", "exists"]

# Create a regular expression pattern to match all quantifiers and their associated path IDs
pattern = r'(forall|exists)\s+([A-Z])\s*\.'

# Use re.findall to extract all matched quantifiers and path IDs
matches = re.findall(pattern, text)

# Create a dictionary to store quantifiers and their associated path IDs
quantifier_path_dict = {}

# Iterate through the matches and populate the dictionary
for match in matches:
	quantifier = match[0]
	path_id = match[1]
	if path_id in quantifier_path_dict:
		quantifier_path_dict[path_id].append(quantifier)
	else:
		quantifier_path_dict[path_id] = [quantifier]

# # Print the dictionary of quantifiers and their associated path IDs
# for quantifier, path_ids in quantifier_path_dict.items():
# 	print(f"{path_ids}: {quantifier}")



binary_ops = re.findall("\(.*?\)", text)
for bins in binary_ops:
	# if it's not a numerical comparison
	if ("*" not in bins):
		# print(bins)
		all_vars = set(re.findall("[a-z0-9\w]+\[", bins))
		# print(all_vars)
		for var in all_vars:
			var = var.replace("[","")
			if(var in bitblasting_dict):
				print("[ !!! HyperBMC error: the variable: ", var, ", is a numerical variable and thus, is not a valid variable for binary operation. ]")
				print("use syntax *<vid>[<pid>] <arith_comp> <vid>[<pid>]* for numerical comparisons.")
				quit()


# sub [\pi] to _\pi
characters = list(quantifier_path_dict.keys())
for i in range(len(characters)):
	pid = characters[i].replace(".","")
	temp = '_'+pid
	text = re.sub("\["+pid+"\]", temp, text)


arith_ops = re.findall("\*.*?\*", text)
for op in arith_ops:
	blasted = ""
	# print(op)
	op = op.replace("*", "")
	if("!="in op):
		vars = op.split("!=")
	elif ("="in op):
		vars = op.split("=")
	else:
		print("[ !!! HyperBMC error: arithmetic comparison is not correctly constructed. Use '=' or '!=' to connect two numerical variables. ]")
		quit()

	# print(vars[0])
	var_l = str(vars[0]).rsplit('_', 1)
	var_r = str(vars[1]).rsplit('_', 1)

	try:
		if (isNumber(var_l[0]) and isNumber(var_r[0])):
			print("[ !!! HyperBMC error: arithmetic operation is not correctly constructed. ]")
			quit()

		elif (isNumber(var_l[0])):
			blasted = binary_assign(var_r, int(var_l[0]))
		elif (isNumber(var_r[0])):
			blasted = binary_assign(var_l, int(var_r[0]))
		else:
			num_bits_left = bitblasting_dict[var_l[0].replace(" ","")]
			num_bits_right = bitblasting_dict[var_r[0].replace(" ","")]
			if(num_bits_left != num_bits_right):
				print("[ !!! HyperBMC error: arithmetic conparison requires two variables with same number of bits in binary representation. ]")
				quit()
			else:
				# print("blasting")
				if("!="in op):
					# print("~"+binary_eq(var_l, var_r))
					blasted = "~"+binary_eq(var_l, var_r)
				else:
					# print(binary_eq(var_l, var_r))
					blasted = binary_eq(var_l, var_r)

		text = text.replace(op, blasted)
	except KeyError:
		print("[ !!! HyperBMC error: arithmetic comparison is not correctly constructed. Boolean variables are not allowed in the comparison. ] ")
		quit()


# clean up arith operations
text = text.replace("*","")

text = text.replace(".","")

if(To_Negate_formula):
	text= "~("+ text + ")"

### finally
print("formula translated into Boolean representation: \n" + text)

def gen_P():
	##  write to R_bool file
	P_bool = open(translated_formula_file_name, "w")
	P_bool.write(text)
	P_bool.close()

gen_P()

print("[ success! input formula translated into Boolean Expressions: "+ translated_formula_file_name+"]")

