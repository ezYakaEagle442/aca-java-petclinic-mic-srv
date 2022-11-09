/*
 * Copyright 2002-2021 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.api.application;

import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.samples.petclinic.api.dto.Visits;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.List;

import static java.util.stream.Collectors.joining;

/**
 * @author Maciej Szarlinski
 */
@Component
@RequiredArgsConstructor
public class VisitsServiceClient {

    /*
    see 
    https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv/issues/1
    https://github.com/microsoft/azure-container-apps/issues/473

    An alternate way of achieving this without getting the fqdn of the app:

    An environment variable: **CONTAINER_APP_ENV_DNS_SUFFIX** is auto-injected for every container running on the environment which describes the environments default domain.

    This environment variable can help formulate the Internal FQDN of the app. e.g.:
    http://<containerapp-name>.internal.<CONTAINER_APP_ENV_DNS_SUFFIX>
    ex: https://myinternalapp.internal.icyforest-6dcfec24.regionname.azurecontainerapps.io

    https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config
    https://www.baeldung.com/spring-boot-properties-env-variables

    */

 
    @Value("${container.app.env.dns.suffix}")
    private String acaEnvDnsSuffix;

    @Value("${visits.svc.url}")
    private String visitsServiceUrl;

    @Autowired
    private Environment environment;

    //String CONTAINER_APP_ENV_DNS_SUFFIX = environment.getProperty("container.app.env.dns.suffix");
    //String VISITS_SVC_URL = environment.getProperty("visits.svc.url");

    String internalK8Ssvc2svcRoute = "http://visits-service.internal." + acaEnvDnsSuffix;

    // Could be changed for testing purpose
    private String hostname = internalK8Ssvc2svcRoute ; // "https://${VISITS_SVC_URL}/";

    private final WebClient.Builder webClientBuilder;

    public Mono<Visits> getVisitsForPets(final List<Integer> petIds) {
        return webClientBuilder.build()
            .get()
            .uri(hostname + "pets/visits?petId={petId}", joinIds(petIds))
            .retrieve()
            .bodyToMono(Visits.class);
    }

    private String joinIds(List<Integer> petIds) {
        return petIds.stream().map(Object::toString).collect(joining(","));
    }

    void setHostname(String hostname) {
        this.hostname = hostname;
    }
}
