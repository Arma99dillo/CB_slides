using Pkg
Pkg.activate("CB")
using MultipleScattering
using Plots

# parameters
cage_radius = 1
n_particles = 30
particle_radius = 0.1*2π/n_particles
rid = 0.9


# define obstacle
X_1 = [
    [cage_radius*cos(θ), cage_radius*sin(θ)]
for θ = 0:2π/n_particles:2π-2π/n_particles ]
X_2 = [
    [-4.0+rid*cage_radius*cos(θ), 4.0+rid*cage_radius*sin(θ)]
for θ = 0:2π/n_particles:2π-2π/n_particles ]
X= [X_1; X_2]

particle_medium =  Acoustic(2; ρ = 0., c = 0.);
Obstacle = [
    if x in X_2
        Particle(particle_medium, Circle(x, particle_radius))
    else
        Particle(particle_medium, Circle(x, particle_radius))   
    end    
for x in X];

using LaTeXStrings
l = @layout [a{0.98h} ; b]
p = plot(Obstacle, fill = (0, 1, :black), xguide ="",yguide ="")
p1 = [-4.0]; p2=[0.0];
P2 = plot!(p1, p2, markershape=:circle, markersize=2.5, color = "black", label=false)
str=L"x_0"
ftr = text(str, :black, :center, 12)
annotate!(-4.0, 0.25, ftr)
savefig("domain.png")

# source
# list_ω = [2.0,2.39,2.405,3.832];
list_ω = [2.39,3.832,6.38];
x0 = [-4.0, 0.0]; 
θ=π/4
host_medium = Acoustic(2; ρ=1.0, c=1.0); # medium of the background, 2 is the dimension of the setting.
source =  point_source(host_medium, x0, 2.0)
#source =  plane_source(host_medium; direction = [cos(θ),sin(θ)])

# region where the result will be plot
bottomleft = [-6.0;-2.5]; topright = [3.0;5.5];
region = Box([bottomleft, topright]);
some_region = Box([[x0[1]-0.01;x0[2]-0.01], [x0[1]+0.01;x0[2]+0.01]]);
result = run(Obstacle, source, region, list_ω,  exclude_region = some_region; res=500)

# plots
for p=1:3
    plot(result,list_ω[p];
        field_apply = real, seriestype = :heatmap,
        clims=(-0.25,0.25),
        title = ""
    );
    p1 = plot!(Obstacle);
    plot(p1)
    savefig("double_obstacle"*string(p)*".png")
end

#animation
ts = LinRange(0.,2pi/list_ω[3],30)
maxc = 0.25
minc = -0.25
anim = @animate for t in ts
    plot(result,list_ω[3]; seriestype = :heatmap,
        region_shape = region, res=500,
        phase_time=t, clim=(minc,maxc),
        c=:balance
    )
    plot!(Obstacle)
    plot!( title="",axis=false, xguide ="",yguide ="")
end
gif(anim,"final3.gif", fps = 15)
