using Pkg
Pkg.activate("CB")
using MultipleScattering
using Plots

dimension = 2;
θ=π/4;
medium = Acoustic(dimension; ρ = 1.0, c = 1.0);
ω = 5.0;
bottomleft = [-1.0;-1.0]; topright = [1.0;1.0];
region = Box([bottomleft, topright]);
source =  plane_source(medium; direction = [cos(θ),sin(θ)])

result = run(source, region, [ω]; res=500)

ts = LinRange(0.,2pi/ω,30)
maxc = 1.0
minc = -1.0
anim = @animate for t in ts
    plot(result,ω; seriestype = :heatmap,
        region_shape = region, res=500,
        phase_time=t, clim=(minc,maxc),
        c=:balance
    )
    plot!(colorbar=false, title="",axis=false, xguide ="",yguide ="")
end
gif(anim,"plane-wave.gif", fps = 20)

#point source
x0 = [-1.0, 1.0]; 
source =  point_source(medium, x0, 2.0)
bottomleft = [-2.0;-1.0]; topright = [1.0;2.0];
region = Box([bottomleft, topright]);
some_region = Box([[x0[1]-0.01;x0[2]-0.01], [x0[1]+0.01;x0[2]+0.01]]);
result = run( source, region, [ω],  exclude_region = some_region; res=500)


ts = LinRange(0.,2pi/ω,30)
maxc = 0.25
minc = -0.25
anim = @animate for t in ts
    plot(result,ω; seriestype = :heatmap,
        region_shape = region, res=500,
        phase_time=t, clim=(minc,maxc),
        c=:balance
    )
    plot!(colorbar=false, title="",axis=false, xguide ="",yguide ="")
end
gif(anim,"point-wave.gif", fps = 20)
