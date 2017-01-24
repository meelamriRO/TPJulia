using Cbc 
using JuMP
using Clp #c'est pour la relaxation 
#=Using Scanner
input = Scan("espaces/travail/s8/outil_logi/tp2/cutting.txt")=#

type cutting
NbItems::Int
RollWidth::Int
Size::Array{Int64,1} 
Amount::Array{Int64,1}
motif::Array{Int64,2} 
end

NbItems = 5
RollWidth = 110
Size = [20, 45, 50, 55, 75]
Amount =[48, 35, 24, 10,8]

motif = [1 0 0 0 1; 0 1 0 0 0; 0 0 1 0 0 ; 1 0 0 1 0; 0 0 0 0 1] 
#=
NbItems = next(input,Int64)
RollWidth = next(input, Int64)
Size = nextarray(input, Int64,5)
Amount = nextarray(input, Int64,5)
motif = nextarray(input,Int64,5,5)
=#
data = cutting(NbItems,RollWidth,Size,Amount,motif)
#m = Model(solver=CbcSolver())




function  sans_relaxation()
	m = Model(solver=CbcSolver())

	@variable(m, x[1:5] >= 0, Int)
	#question 2 pour la relaxation faut rajouter le package Clp 

	@objective(m, Min, sum(x[i] for i in 1:data.NbItems))

	@constraint(m,dem[i in 1:data.NbItems], sum(data.motif[i,p]*x[p] for p in 1:5) >= data.Amount[i])

	print(m)
	solve(m)
	@show getvalue(x)
	#c'est pour récuperer la valeur de l'objectif :,@show getobjectivevalue(m)
	println("l'objectif : " ,getobjectivevalue(m))
end


resultat_sans_la_relaxation=sans_relaxation()
println("le programme lineaire avec la relaxation")


function relaxation(data)
	m = Model(solver=ClpSolver())

	@variable(m, x[1:5] >= 0)
	#question 2 pour la relaxation faut rajouter le package Clp 

	@objective(m, Min, sum(x[i] for i in 1:data.NbItems))

	@constraint(m,dem[i in 1:data.NbItems], sum(data.motif[i,p]*x[p] for p in 1:5) >= data.Amount[i])
	print(m)
	solve(m)
	@show getvalue(x)
	#c'est pour récuperer la valeur de l'objectif :,@show getobjectivevalue(m)
	println("l'objectif : " ,getobjectivevalue(m))

	v=getdual(dem)
	return v
end

println("chercher les valeurs duals ")
vdual = relaxation(data)
@show vdual


######################################### Cout resuit ###############################################
println("les valeurs du cout reduit sontttttttt :")


function coutreduit(data)
	n = Model(solver=CbcSolver())
	@variable(n, y[1:NbItems] >= 0, Int)

	@objective(n, Min, 1- sum(y[i] *vdual[i] for i in 1:data.NbItems ) )
	@constraint (n,cap, sum(y[i] *data.Size[i] for i in 1:data.NbItems) <=110 )

	print(n)
	solve(n)
	@show getvalue(y)
end 
coutReduit= coutreduit(data)
println("chercher les valeurs du cout reduit ")
#coutReduit= cout_reduit(data)











