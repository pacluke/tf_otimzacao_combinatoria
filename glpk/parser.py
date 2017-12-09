import sys
with (open(sys.argv[1], 'r')) as f_in:
           lines = f_in.read().splitlines()
           state = 0
           nodes_dict = {}
           values_dict = {}
           max_cost = 0
           initial = 0
           for line in lines:
               print(line)
               split_line = line.split()
               if (split_line[0] == "NAME" and state == 0):
                   name = split_line[2]
               elif (split_line[0] == "COST_LIMIT" and state == 0):
                   max_cost = split_line[2]
               elif (split_line[0] == "NODE_COORD_SECTION" and state == 0):
                   state = 1
                   
               elif (state == 1):
                   if (split_line[0] == "NODE_SCORE_SECTION"):
                       state = 2
                   else:
                       print("split_line0: ", split_line[0])
                       print("split_line1: ", split_line[1])
                       print("split_line2: ", split_line[2])
                       nodes_dict[split_line[0]] = [split_line[1], split_line[2]]
               elif (state == 2):
                   if (split_line[0] == "DEPOT_SECTION"):
                       state = 3
                   else:
                       values_dict[split_line[0]] = split_line[1]
               elif (state == 3):
                   initial = split_line[0]
                   break
with (open(sys.argv[2], 'w')) as f_out:
            f_out.write("data;\n\n")
            f_out.write("set N :=")
            for key in nodes_dict.keys():
                f_out.write(" " + key)
            f_out.write(";\n\nparam x := ")
            for key in nodes_dict.keys():
                f_out.write("\n" + key + " " + nodes_dict[key][0])
                
            f_out.write(";\n\nparam y := ")
            for key in nodes_dict.keys():
                f_out.write("\n" + key + " " + nodes_dict[key][1])

            f_out.write(";\n\nparam r := ")
            for key in values_dict.keys():
                f_out.write("\n" + key + " " + values_dict[key])

            f_out.write(";\n\nparam i := " + initial + ";")
            f_out.write("\n\nparam c := " + max_cost + ";")
            f_out.write("\n\nend;")
