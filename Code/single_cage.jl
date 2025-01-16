using Pkg
Pkg.activate("CB")
using MultipleScattering
using Plots

# parameters
cage_radius = 1
n_particles = 30
particle_radius = 0.1*2π/n_particles


# define obstacle
X = [
    [cage_radius*cos(θ), cage_radius*sin(θ)]
for θ = 0:2π/n_particles:2π-2π/n_particles ]

particle_medium =  Acoustic(2; ρ = 0., c = 0.);
Obstacle = [
    Particle(particle_medium, Circle(x, particle_radius))
for x in X];
plot(Obstacle, fill = (0, 1, :black), axis=false, xguide ="",yguide ="")
savefig("wire.png")

# source
list_ω = [2.0,2.39,2.405,3.832];
list_ω = [6.38];
x0 = [2.0, 0.0]; 
host_medium = Acoustic(2; ρ=1.0, c=1.0); # medium of the background, 2 is the dimension of the setting.
source =  point_source(host_medium, x0)
# source =  plane_source(host_medium; direction = [1.0,0.0])

# region where the result will be plot
bottomleft = [-1.5;-2]; topright = [2.5;2];
region = Box([bottomleft, topright]);
some_region = Box([[x0[1]-0.01;x0[2]-0.01], [x0[1]+0.01;x0[2]+0.01]]);
result = run(Obstacle, source, region, list_ω,  exclude_region = some_region; res=500)

# plots
for p=1:1
    plot(result,list_ω[p];
        field_apply = real, seriestype = :heatmap,
        clims=(-.25,.25),
        title = "k="*string(list_ω[p])
    );
    p1 = plot!(Obstacle);
    plot!(axis=false, xguide ="",yguide ="")
    plot(p1)
    savefig("resonant_plot_"*string(p+4)*".png")
end



#animation
ts = LinRange(0.,2pi/list_ω[1],30)
maxc = 0.2
minc = -0.2
anim = @animate for t in ts
    plot(result,list_ω[1]; seriestype = :heatmap,
        region_shape = region, res=500,
        phase_time=t, clim=(minc,maxc),
        c=:balance
    )
    plot!(Obstacle)
    plot!( title="",axis=false, xguide ="",yguide ="")
end
gif(anim,"resonant_j3.gif", fps = 10)

