using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;



[RequireComponent(typeof(Renderer))]
public class CurlNoise : MonoBehaviour {
    public Transform emission;
    public int numParticles = 10000;
    public float speed;
    float time;

    #region GPU
    public ComputeShader cs;
    ComputeBuffer bufferRead;
    ComputeBuffer bufferWrite;
    static int SIMULATION_BLOCK_SIZE = 32;
    int threadGroupSize;
    #endregion GPU
    
    Particle[] particles;
    int maxParticleNum;

    void Start() {
        time = 0;
        MakeBodies();
        InitializeBuffer();
    }

    void Update() {

        time += Time.deltaTime;

        cs.SetFloat("_DT", Time.deltaTime);
        cs.SetVector("_EmitPos", emission.position);
        cs.SetFloat("_Speed", speed);
        cs.SetFloat("_Time", time);

        cs.SetBuffer(0, "bufferRead", bufferRead);
        cs.SetBuffer(0, "bufferWrite", bufferWrite);
        cs.Dispatch(0, threadGroupSize, 1, 1);

        SwapBuffer();
    }

    void OnDestroy() {
        if(bufferRead != null) {
            bufferRead.Release();
            bufferRead = null;
        }
        if(bufferWrite != null) {
            bufferWrite.Release();
            bufferWrite = null;
        }
    }

    void MakeBodies() {

        particles = new Particle[numParticles];
        for (int i = 0; i < numParticles; i++) {
            particles[i] = new Particle(Random.insideUnitSphere, Random.insideUnitSphere, Random.Range(0.5f, 2f));
        }
        maxParticleNum = particles.Length;
    }

    void InitializeBuffer() {
        bufferRead = new ComputeBuffer(maxParticleNum, Marshal.SizeOf(typeof(Particle)));
        bufferWrite = new ComputeBuffer(maxParticleNum, Marshal.SizeOf(typeof(Particle)));
        bufferRead.SetData(particles);
        bufferWrite.SetData(particles);
        threadGroupSize = Mathf.CeilToInt(maxParticleNum / SIMULATION_BLOCK_SIZE) + 1;
    }

    void SwapBuffer() {
        ComputeBuffer tmp = bufferRead;
        bufferRead = bufferWrite;
        bufferWrite = tmp;
    }

    public ComputeBuffer GetBuffer() {
        return bufferRead;
    }

    public int GetMaxParticleNum() {
        return maxParticleNum;
    }

}

struct Particle {
    Vector3 birthPos;
    Vector3 pos;
    float time;
    float life;

    public Particle(Vector3 bPos, Vector3 pos, float life) {
        birthPos = bPos;
        this.pos = pos;
        this.time = 0;
        this.life = life;
    }
}

