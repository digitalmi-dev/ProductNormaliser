FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore ProductNormaliser.slnx
RUN dotnet build ProductNormaliser.slnx -c Release --no-restore
RUN dotnet test ProductNormaliser.Domain.Tests -c Release --no-build && dotnet test ProductNormaliser.Web.Tests -c Release --no-build
RUN dotnet publish ProductNormaliser.Web -c Release --no-restore -o /out/Web && dotnet publish ProductNormaliser.AdminApi -c Release --no-restore -o /out/AdminApi && dotnet publish ProductNormaliser.Worker -c Release --no-restore -o /out/Worker

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /out /app
ENV ASPNETCORE_ENVIRONMENT=Production DOTNET_ENVIRONMENT=Production PN_SERVICE=Web ASPNETCORE_URLS=http://[::]:8080 Llm__Enabled=false
EXPOSE 8080
USER app
CMD ["sh", "-c", "case \"$PN_SERVICE\" in Web|AdminApi|Worker) cd /app/\"$PN_SERVICE\" && exec dotnet ProductNormaliser.\"$PN_SERVICE\".dll ;; *) echo Invalid_PN_SERVICE >&2; exit 1 ;; esac"]
