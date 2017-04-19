using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour {

    public float amplitude;
    public float speed = 1;
    public float yPos;
    float time = 0;

    public float a = 1;
    public float b = 2;
    public float c = 3;

	// Use this for initialization
	void Start () {
        time = 0;
	}
	
	// Update is called once per frame
	void Update () {
        time += Time.deltaTime;
        // transform.position = speed * new Vector3(Mathf.Sin(1 * time + a), Mathf.Sin(2 * time + b), 0);
        transform.position = new Vector3(amplitude * Mathf.Sin(speed * time), 10*(Mathf.PerlinNoise(time, time)*2-1),0);
    }
}
